require Logger

defmodule ElixirFakeIm.SIO do

  alias ElixirFakeIm.UserPool

  def read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def write_line(socket, {:ok, name}) do
    :gen_tcp.send(socket, "Sending [#{name}]: LOGGED IN\r\n")
  end

  def write_line(socket, {:error, :login_required}) do
    :gen_tcp.send(socket, "LOGIN REQUIRED\r\n")
  end

  def write_line(socket, name, {:ok, msg, [{_to_user, to_socket} | users]}) do
    :gen_tcp.send(to_socket, "Sending [#{name}]: #{msg}\r\n")
    write_line(socket, name, {:ok, msg, users})
  end
  def write_line(_socket, _name, {:ok, _msg, []}), do: []

  def write_line(socket, _name, {:error, :msg, error_msg}) do
    :gen_tcp.send(socket, "#{error_msg}\r\n")
  end

  def write_line(_socket, name, {:error, :closed}) do
    ua_shutdown(name)
    exit(:shutdown)
  end

  def write_line(socket, name, {:error, error}) do
    ua_shutdown(name)
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end

  def ua_shutdown(name) do
    {:ok, ua_pid} = UserPool.lookup(UserPool, name)
    Process.exit(ua_pid, :shutdown)
  end

end
