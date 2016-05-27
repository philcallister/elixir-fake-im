defmodule ElixirFakeIm.GroupAgent do

  def start_link do
    Agent.start_link(fn -> [] end)
  end

  def get_sockets(ga) do
	Agent.get(ga, &(&1))
  end

  def add_socket(ga, socket) do
    Agent.update(ga, fn list -> [socket | list] end)
  end

end
