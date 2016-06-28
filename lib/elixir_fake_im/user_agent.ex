defmodule ElixirFakeIm.UserAgent do

  def start_link do
    Agent.start_link(fn -> %{user_pid: nil, groups: []} end)
  end

  def get_user(ua) do
    Agent.get(ua, &Map.get(&1, :user_pid))
  end

  def put_user(ua, value) do
    Agent.update(ua, &Map.put(&1, :user_pid, value))
  end

  def get_groups(ua) do
    Agent.get(ua, &Map.get(&1, :groups))
  end

  def is_subscribed?(ua, group) do
    groups = Agent.get(ua, &Map.get(&1, :groups))
    !!Enum.find(groups, fn(g) -> g == group end)
  end

  def add_group(ua, value) do
    Agent.update(ua, fn(map) ->
      groups = Map.get(map, :groups)
      Map.put(map, :groups, [value | groups])
    end)
  end

  def remove_group(ua, value) do
    Agent.update(ua, fn(map) ->
      Map.update!(map, :groups, &(List.delete(&1, value)))
    end)
  end

end
