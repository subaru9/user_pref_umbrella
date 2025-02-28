defmodule SharedUtils.Cachable.Agent do
  @moduledoc """
  An Agent-based implementation of the Cachable behaviour.
  """

  @behaviour SharedUtils.Cachable

  use Agent

  def start_link(opts \\ []) do
    name = Keyword.fetch!(opts, :name)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @impl true
  def get(name, key) do
    Agent.get(name, fn state -> Map.get(state, key) end)
  end

  @impl true
  def put(name, key, value) do
    Agent.update(name, fn state -> Map.put(state, key, value) end)
  end

  @impl true
  def delete(name, key) do
    Agent.update(name, fn state -> Map.delete(state, key) end)
  end

  @impl true
  def clear(name) do
    Agent.update(name, fn _ -> %{} end)
  end
end
