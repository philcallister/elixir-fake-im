defmodule ElixirFakeIm.UserAgent do

  def start_link do
    Agent.start_link(fn -> %{socket: nil, groups: []} end)
  end

  def get_socket(ua) do
    Agent.get(ua, &Map.get(&1, :socket))
  end

  def put_socket(ua, value) do
    Agent.update(ua, &Map.put(&1, :socket, value))
  end

  def get_groups(ua) do
    Agent.get(ua, &Map.get(&1, :groups))
  end

  def add_group(ua, value) do
    Agent.update(ua, fn(map) ->
      groups = Map.get(map, :groups)
      Map.put(map, :groups, [value | groups]) end)
  end

end
