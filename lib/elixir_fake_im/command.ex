require Logger

alias ElixirFakeIm.UserPool
alias ElixirFakeIm.MQ

defmodule ElixirFakeIm.Command do

  ##
  # Login
  # > login:<user>
  def parse_login(line) do
    case String.split(line, ":", trim: true) |> Enum.map(&String.strip(&1)) do
      ["login", user] when byte_size(user) > 0 -> {:ok, user}
      _ -> {:error, :login_required}
    end
  end

  ## login:<user>
  def run_login(socket, {:ok, user}) do
    {:ok, mq_pid} = UserPool.create(UserPool, user)
    MQ.put_socket(mq_pid, socket)
    Logger.info("Login: #{user}")
    {:ok, user}
  end

  ##
  # Commands
  # > logout
  # > user:<user>:<msg>
  def parse(line) do
    case String.split(line, ":", trim: true) |> Enum.map(&String.strip(&1)) do
      ["logout"] -> {:ok, :logout}
      ["user", to_user, msg]  when byte_size(to_user) > 0 -> {:ok, {:user, to_user, msg}}
      _ -> {:error, :msg, "UNKNOWN COMMAND"}
    end
  end

  def run(_socket, from_user, :logout) do
    Logger.info("Logout: #{from_user}")
    {:error, :closed}
  end

  def run(_socket, _from_user, {:user, to_user, msg}) do
    case UserPool.lookup(UserPool, to_user) do
      {:ok, mq_pid} ->
        to_socket = MQ.get_socket(mq_pid)
        {:ok, msg, [{to_user, to_socket}]}
      :error ->
        {:error, :msg, "[#{to_user}] USER DISCONNECTED"}
    end
  end

end
