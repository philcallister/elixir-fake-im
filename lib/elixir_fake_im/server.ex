require Logger

defmodule ElixirFakeIm.Server do

  alias ElixirFakeIm.Connection

  def accept(port) do
    opts = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ElixirFakeIm.SocketSupervisor, fn -> Connection.login(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

end
