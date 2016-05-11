require Logger

defmodule ElixirFakeIm.Command do

  def parse(line) do
    case String.split(line, ":", trim: true) do
      ["login", user] -> {:ok, {:login, user}}
      _ -> {:error, :unknown_command}
    end
  end

end