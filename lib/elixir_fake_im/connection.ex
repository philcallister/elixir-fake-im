require Logger
require ElixirFakeIm.Broadcast

defmodule ElixirFakeIm.Connection do

  alias ElixirFakeIm.Command

  def start_connection(socket) do
    {:ok, user_pid} = Task.start_link(fn -> publish(socket) end)
    login(socket, user_pid)
  end

  defp publish(socket) do
    receive do
      msg -> :gen_tcp.send(socket, msg)
    end
    publish(socket)
  end

  ##
  # Loop for login here...
  def login(socket, user_pid) do
    msg = 
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} ->
          case Command.parse_login(data) do
            {:ok, _user} = command -> Command.run_login(user_pid, command)
            {:error, _} = error -> error
          end
        {:error, _} = error -> error
      end

    Logger.info("Message: #{inspect(msg)}")
    ElixirFakeIm.Broadcast.broadcast(user_pid, msg)

    case msg do
      {:error, _} -> login(socket, user_pid)
      _ -> serve(socket, user_pid, msg)
    end

  end

  ##
  # Loop for commands here...
  defp serve(socket, user_pid, {:ok, from_user}) do
    msg = 
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} ->
          case Command.parse(data) do
            {:ok, command} -> Command.run(user_pid, from_user, command)
            {:error, _} = error -> error
            {:error, _, _} = error -> error
         end
        {:error, _} = error -> error
      end

    Logger.info("Message: #{inspect(msg)}")
    ElixirFakeIm.Broadcast.broadcast(user_pid, from_user, msg)
    serve(socket, user_pid, {:ok, from_user})
  end

end
