require Logger

alias ElixirFakeIm.UserPool
alias ElixirFakeIm.MQ

defmodule ElixirFakeIm.Command do

  def parse_login(line) do
    case String.split(line, ":", trim: true) do
      ["login", user] -> {:ok, String.strip(user)}
      _ -> {:error, :login_required}
    end
  end

  def run_login(socket, {:ok, user}) do
    {:ok, mq_pid} = UserPool.create(UserPool, user)
    MQ.put_socket(mq_pid, socket)
    Logger.info("Login: #{user}")
    {:ok, user}
  end

  def parse(line) do
    case String.split(line, ":", trim: true) do
      ["user", to_user, msg] -> {:ok, {:user, String.strip(to_user), msg}}
      _ -> {:error, :unknown_command}
    end
  end

  def run(_socket, {:user, to_user, msg}) do
    {:ok, mq_pid} = UserPool.lookup(UserPool, to_user)
    to_socket = MQ.get_socket(mq_pid)
    {:ok, msg, [{to_user, to_socket}]}
  end

end
