defmodule SharedUtils.Cachable.GenServer do
  @moduledoc """
  A GenServer-based implementation of the Cachable behaviour.

  This module replaces the Agent-based implementation to better integrate with libraries like 
  `Singleton` that expect a `GenServer`-compatible process. The switch to `GenServer` resolves 
  the `:undef` error encountered when attempting to start a process under `Singleton` using an 
  `Agent`, which lacks the required `init/1` callback.

  ## Advantages of Using GenServer

  - **Compatibility**: Fully compatible with libraries like `Singleton` that rely on the OTP 
    conventions of `start_link/1` and `init/1`.
  - **Customization**: Allows more flexibility in handling state initialization and lifecycle 
    management compared to `Agent`.

  ## Usage

      # Start the GenServer-based cache
      SharedUtils.Cachable.GenServer.start_link(name: :my_cache)

      # Use the cache functions
      SharedUtils.Cachable.GenServer.put(:my_cache, "key", "value")
      SharedUtils.Cachable.GenServer.get(:my_cache, "key") # => "value"

  """

  @behaviour SharedUtils.Cachable

  use GenServer

  # Public API

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @impl true
  @spec get(atom(), any()) :: any()
  def get(name, key) do
    GenServer.call(name, {:get, key})
  end

  @impl true
  @spec put(atom(), any(), any()) :: :ok
  def put(name, key, value) do
    GenServer.cast(name, {:put, key, value})
  end

  @impl true
  @spec delete(atom(), any()) :: :ok
  def delete(name, key) do
    GenServer.cast(name, {:delete, key})
  end

  @impl true
  @spec clear(atom()) :: :ok
  def clear(name) do
    GenServer.cast(name, :clear)
  end

  # Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key, nil), state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end
end
