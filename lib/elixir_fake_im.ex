require Logger

defmodule ElixirFakeIm do
  @moduledoc """
  This is documentation for the project.
  """
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: ElixirFakeIm.SocketSupervisor]]),
      supervisor(ElixirFakeIm.UserAgentSupervisor, []),
      supervisor(ElixirFakeIm.GroupAgentSupervisor, []),
      worker(ElixirFakeIm.UserPool, []),
      worker(ElixirFakeIm.GroupPool, []),
      worker(Task, [ElixirFakeIm.Server, :accept, [10408]])
    ]

    opts = [strategy: :one_for_one, name: ElixirFakeIm.Supervisor]
    Supervisor.start_link(children, opts)
  end

end