require Logger

defmodule Mix.Tasks.ElixirFakeIm.Server do

  use Mix.Task

  @shortdoc "Starts the server"

  @moduledoc """
  Starts the Elixir Fake IM server.
  ## Command line options
  This task accepts the same command-line arguments as `run`.
  For additional information, refer to the documentation for
  `Mix.Tasks.Run`.
  """
  def run(args) do
    Logger.info("Starting Elixir Fake IM Server...")
    Mix.Task.run "run", ["--no-halt"] ++ args
  end

end
