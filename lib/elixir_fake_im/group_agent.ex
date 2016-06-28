defmodule ElixirFakeIm.GroupAgent do

  def start_link do
    Agent.start_link(fn -> [] end)
  end

  def get_users(ga) do
    Agent.get(ga, &(&1))
  end

  def add_user(ga, user_pid) do
    Agent.update(ga, fn list -> [user_pid | list] end)
  end

  def remove_user(ga, user_pid) do
    Agent.update(ga, &(List.delete(&1, user_pid)))
  end

end
