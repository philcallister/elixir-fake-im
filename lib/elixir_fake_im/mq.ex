defmodule ElixirFakeIm.MQ do

  def start_link do
    Agent.start_link(fn -> %{socket: nil} end)
  end

  def get_socket(mq) do
    Agent.get(mq, &Map.get(&1, :socket))
  end

  def put_socket(mq, value) do
    Agent.update(mq, &Map.put(&1, :socket, value))
  end

end