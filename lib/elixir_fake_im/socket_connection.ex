require Logger

defmodule ElixirFakeIm.SocketConnection do

  alias ElixirFakeIm.Command
  alias ElixirFakeIm.SIO

  ##
  # Loop for login here...
  def login(socket) do
    msg = 
      case SIO.read_line(socket) do
        {:ok, data} ->
          case Command.parse_login(data) do
            {:ok, _user} = command -> Command.run_login(socket, command)
            {:error, _} = error -> error
          end
        {:error, _} = error -> error
      end

    SIO.write_line(socket, msg)

    case msg do
      {:error, _} -> login(socket)
      _ -> serve(socket, msg)
    end

  end

  ##
  # Loop for commands here...
  defp serve(socket, {:ok, from_user}) do
    msg = 
      case SIO.read_line(socket) do
        {:ok, data} ->
          case Command.parse(data) do
            {:ok, command} -> Command.run(socket, from_user, command)
            {:error, _} = error -> error
            {:error, _, _} = error -> error
         end
        {:error, _} = error -> error
      end
    SIO.write_line(socket, from_user, msg)
    serve(socket, {:ok, from_user})
  end

end
