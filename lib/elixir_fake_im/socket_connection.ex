require Logger

defmodule ElixirFakeIm.SocketConnection do

  alias ElixirFakeIm.UserPool
  alias ElixirFakeIm.MQ

  def serve(socket) do
    msg_name =
      case read_line(socket) do
        {:ok, name} ->
          name_received(socket, name)
        {:error, _} = error -> 
          error
      end
    write_line(socket, msg_name)
    serve(socket, msg_name)
  end

  defp name_received(socket, name) do
    stripped = String.strip(name)
    Logger.info("User: #{stripped}")
    {:ok, mq_pid} = UserPool.create(UserPool, stripped)
    MQ.put_socket(mq_pid, socket)
    {:ok, stripped}
  end

  defp serve(socket, msg_name) do
    msg =
      case read_line(socket) do
        {:ok, data} ->
          Logger.info("[#{elem(msg_name, 1)}] Received: #{data}")
          String.split(data, " ", trim: true)
          {:ok, String.split(data, ":", trim: true)}
        {:error, _} = error -> {error, msg_name}
      end
    write_line(socket, msg)
    serve(socket, msg_name)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(_socket, {:ok, [name|msg]}) do
    {:ok, mq_pid} = UserPool.lookup(UserPool, name)
    socket = MQ.get_socket(mq_pid)
    :gen_tcp.send(socket, "Sending [#{name}]: #{msg}\n")
  end

  defp write_line(socket, {{:error, :unknown_command}, {:ok, name}}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\n")
  end

  defp write_line(_socket, {{:error, :closed}, {:ok, name}}) do
    mq_shutdown(name)
    exit(:shutdown)
  end

  defp write_line(socket, {{:error, error}, {:ok, name}}) do
    mq_shutdown(name)
    :gen_tcp.send(socket, "ERROR\n")
    exit(error)
  end

  defp mq_shutdown(name) do
    {:ok, mq_pid} = UserPool.lookup(UserPool, name)
    Process.exit(mq_pid, :shutdown)
  end

end
