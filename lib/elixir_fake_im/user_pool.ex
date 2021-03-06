require Logger

defmodule ElixirFakeIm.UserPool do
  use GenServer

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  
  ## Server callbacks

  def init(:ok) do
    {:ok, {%{}, %{}}}
  end

  def handle_call({:lookup, name}, _from, {names, refs}) do
    {:reply, Map.fetch(names, name), {names, refs}}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    if !Map.has_key?(names, name) do
      {:ok, ua_pid} = ElixirFakeIm.UserAgentSupervisor.start_user_agent
      ref = Process.monitor(ua_pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, ua_pid)
    end
    {:reply, Map.fetch(names, name), {names, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
