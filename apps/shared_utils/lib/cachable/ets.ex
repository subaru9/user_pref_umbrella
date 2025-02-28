defmodule SharedUtils.Cachable.ETS do
  @moduledoc """
  An ETS-based implementation of the Cachable behaviour.
  """

  @behaviour SharedUtils.Cachable

  def init(opts \\ []) do
    name = Keyword.fetch!(opts, :name)
    table_opts = Keyword.fetch!(opts, :opts)

    if :ets.info(name) === :undefined do
      :ets.new(name, table_opts)
    end

    :ok
  end

  @impl true
  def get(name, key) do
    case :ets.lookup(name, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  @impl true
  def put(name, key, value) do
    :ets.insert(name, {key, value})
    :ok
  end

  @impl true
  def delete(name, key) do
    :ets.delete(name, key)
    :ok
  end

  @impl true
  def clear(name) do
    :ets.delete_all_objects(name)
    :ok
  end
end
