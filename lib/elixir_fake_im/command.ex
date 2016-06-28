require Logger

alias ElixirFakeIm.UserPool
alias ElixirFakeIm.UserAgent
alias ElixirFakeIm.GroupPool
alias ElixirFakeIm.GroupAgent

defmodule ElixirFakeIm.Command do

  ##
  # Login
  # --------------------------------------------------------------------------
  # login:<user>

  def parse_login(line) do
    case String.split(line, ":", trim: true) |> Enum.map(&String.strip(&1)) do
      ["login", user] when user != "" -> {:ok, user}
      _ -> {:error, :login_required}
    end
  end

  ## login:<user>
  def run_login(user_pid, {:ok, user}) do
    {:ok, ua_pid} = UserPool.create(UserPool, user)
    UserAgent.put_user(ua_pid, user_pid)
    Logger.info("Login: #{user}")
    {:ok, user}
  end

  ##
  # Commands
  # --------------------------------------------------------------------------
  # logout                    | Logout/Disconnect
  # user:<user>:<msg>         | Send given user a message
  # --------------------------------------------------------------------------
  # group:list                | List subscribed groups
  # group:subscribe:<group>   | Subscribe to the group
  # group:unsubscribe:<group> | Unsubscribe from the group
  # group:<group>:<msg>       | Send a message to the group

  def parse(line) do
    case String.split(line, ":", trim: true) |> Enum.map(&String.strip(&1)) do
      ["logout"] -> {:ok, {:logout}}
      ["user", to_user, msg]  when to_user != "" -> {:ok, {:user, to_user, msg}}
      ["group", "list"] -> {:ok, {:group, :list}}
      ["group", "subscribe", group] -> {:ok, {:group, :subscribe, group}}
      ["group", "unsubscribe", group] -> {:ok, {:group, :unsubscribe, group}}
      ["group", group, msg] when group != "" -> {:ok, {:group, group, msg}}
      _ -> {:error, :msg, "UNKNOWN COMMAND"}
    end
  end

  # --------------------------------------------------------------------------

  ## logout
  def run(_user_pid, from_user, {:logout}) do
    Logger.info("Logout: #{from_user}")
    {:error, :closed}
  end

  ## user:<to_user>:<msg>
  def run(_user_pid, _from_user, {:user, to_user, msg}) do
    case UserPool.lookup(UserPool, to_user) do
      {:ok, ua_pid} ->
        to_user_pid = UserAgent.get_user(ua_pid)
        {:ok, msg, [{to_user, to_user_pid}]}
      :error ->
        {:error, :msg, "[#{to_user}] USER DISCONNECTED"}
    end
  end

  # --------------------------------------------------------------------------

  ## group:list
  def run(user_pid, from_user, {:group, :list}) do
    {:ok, ua_pid} = UserPool.lookup(UserPool, from_user)
    groups = UserAgent.get_groups(ua_pid)
    msg = case groups do
      [] -> "[]"
      _  ->
        s = Enum.reduce(groups, fn(x, acc) -> "#{acc} | #{x}" end)
        "[#{s}]"
    end
    {:ok, msg, [{from_user, user_pid}]}
  end

  ## group:subscribe:<group>
  def run(user_pid, from_user, {:group, :subscribe, group}) do
    {:ok, ga_pid} = GroupPool.create(GroupPool, group)
    GroupAgent.add_user(ga_pid, user_pid)
    {:ok, ua_pid} = UserPool.lookup(UserPool, from_user)
    UserAgent.add_group(ua_pid, group)
    {:ok, "GROUP:SUBSCRIBE:#{group}", [{from_user, user_pid}]}
  end

  ## group:unsubscribe:<group>
  def run(user_pid, from_user, {:group, :unsubscribe, group}) do
    {:ok, ga_pid} = GroupPool.lookup(GroupPool, group)
    GroupAgent.remove_user(ga_pid, user_pid)
    if GroupAgent.get_users(ga_pid) == [] do
      Agent.stop(ga_pid)
    end
    {:ok, ua_pid} = UserPool.lookup(UserPool, from_user)
    UserAgent.remove_group(ua_pid, group)
    {:ok, "GROUP:UNSUBSCRIBE:#{group}", [{from_user, user_pid}]}
  end

  ## group:<group>:<msg>
  def run(_user_pid, from_user, {:group, group, msg}) do
    {:ok, ua_pid} = UserPool.lookup(UserPool, from_user)
    case UserAgent.is_subscribed?(ua_pid, group) do
      true -> 
        {:ok, ga_pid} = GroupPool.lookup(GroupPool, group)
        users = GroupAgent.get_users(ga_pid)
        groups = Enum.map(users, fn(to_user) -> {from_user, to_user} end)
        {:ok, msg, groups}
      _ ->
        {:error, :msg, "NOT SUBSCRIBED TO [#{group}]"}
    end
  end

end
