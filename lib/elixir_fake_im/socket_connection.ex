require Logger

defmodule ElixirFakeIm.SocketConnection do

  alias ElixirFakeIm.Command
  alias ElixirFakeIm.UserPool

  ##
  # Wait for login here...
  def login(socket) do
    msg = 
      case read_line(socket) do
        {:ok, data} ->
          case Command.parse_login(data) do
            {:ok, _user} = command ->
              Command.run_login(socket, command)
            {:error, _} = error ->
              error
          end
        {:error, _} = error ->
          error
      end

    write_line(socket, msg)

    case msg do
      {:error, _} -> 
        login(socket)
      _ ->
        serve(socket, msg)
    end

  end

  defp serve(socket, {:ok, from_name}) do
    msg = 
      case read_line(socket) do
        {:ok, data} ->
          case Command.parse(data) do
            {:ok, command} ->
              Command.run(socket, command)
            {:error, _} = error ->
              error
          end
        {:error, _} = error -> error
      end
    write_line(socket, from_name, msg)
    serve(socket, {:ok, from_name})
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, name}) do
    :gen_tcp.send(socket, "Sending [#{name}]: LOGGED IN\n")
  end

  defp write_line(socket, {:error, :login_required}) do
    :gen_tcp.send(socket, "LOGIN REQUIRED\n")
  end

  defp write_line(socket, name, {:ok, msg, [{_to_user, to_socket}|users]}) do
    :gen_tcp.send(to_socket, "Sending [#{name}]: #{msg}\n")
    write_line(socket, name, {:ok, msg, users})
  end
  defp write_line(_socket, _name, {:ok, _msg, []}), do: []


  defp write_line(socket, _name, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\n")
  end

  defp write_line(_socket, name, {:error, :closed}) do
    mq_shutdown(name)
    exit(:shutdown)
  end

  defp write_line(socket, name, {:error, error}) do
    mq_shutdown(name)
    :gen_tcp.send(socket, "ERROR\n")
    exit(error)
  end

  defp mq_shutdown(name) do
    {:ok, mq_pid} = UserPool.lookup(UserPool, name)
    Process.exit(mq_pid, :shutdown)
  end

end
