require Logger

defmodule ElixirFakeIm.Broadcast do

  alias ElixirFakeIm.UserPool

  def broadcast(user_pid, {:ok, name}) do
    send(user_pid, "Sending [#{name}]: LOGGED IN\r\n")
  end

  def broadcast(user_pid, {:error, :login_required}) do
    send(user_pid, "LOGIN REQUIRED\r\n")
  end

  def broadcast(user_pid, name, {:ok, msg, [{_to_user, to_pid} | users]}) do
    send(to_pid, "Sending [#{name}]: #{msg}\r\n")
    broadcast(user_pid, name, {:ok, msg, users})
  end
  def broadcast(_user_pid, _name, {:ok, _msg, []}), do: []

  def broadcast(user_pid, _name, {:error, :msg, error_msg}) do
    send(user_pid, "#{error_msg}\r\n")
  end

  def broadcast(_user_pid, name, {:error, :closed}) do
    ua_shutdown(name)
    exit(:shutdown)
  end

  def broadcast(user_pid, name, {:error, error}) do
    ua_shutdown(name)
    send(user_pid, "ERROR\r\n")
    exit(error)
  end

  def ua_shutdown(name) do
    {:ok, ua_pid} = UserPool.lookup(UserPool, name)
    Process.exit(ua_pid, :shutdown)
  end

end
