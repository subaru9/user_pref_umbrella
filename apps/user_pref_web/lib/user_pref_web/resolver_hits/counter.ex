defmodule UserPrefWeb.ResolverHits.Counter do
  @moduledoc """
  This module prioritizes cache consistency and speed.
  It uses the Singleton library to ensure the cache restarts
  if a node goes down. 

  Future improvements could include regidration
  of the cache after a crash using Redis or PostgreSQL. 

  A GenServer replaces an Agent here to comply with the 
  Singleton library's requirement for an `init` function.

  The singleton processes are colocated with resolvers 
  to minimize in-node communication delays and simplify debugging and maintenance.

  Could be registered as local as well as global process
  """
  use GenServer

  require Logger

  alias UserPrefWeb.ResolverHits

  @type resolver_name :: String.t()
  @type local_name :: atom()
  @type global_name :: {:global, local_name()}
  @type name :: local_name() | global_name()
  @type opts :: [{:name, name()}, {:task_supervisor_name, name()}]
  @type state :: %{name: name(), task_supervisor_name: name()}

  @spec start_link(opts()) :: {:ok, pid()} | {:error, any()} | :ignore
  def start_link(opts \\ []) do
    name = Keyword.fetch!(opts, :name)
    task_supervisor_name = Keyword.fetch!(opts, :task_supervisor_name)
    state = %{name: name, task_supervisor_name: task_supervisor_name}

    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  @spec init(state()) :: {:ok, state()}
  def init(%{task_supervisor_name: task_supervisor_name} = state) do
    {:ok, _pid} = Task.Supervisor.start_link(name: task_supervisor_name)

    {:ok, state}
  end

  @spec increment(resolver_name()) :: :ok
  def increment(resolver_name) do
    %{counter_name: name} = config()
    GenServer.cast(name, {:increment, resolver_name})
  end

  @impl true
  @spec handle_cast({:increment, resolver_name()}, state()) :: {:noreply, state()}
  def handle_cast(
        {:increment, resolver_name},
        %{task_supervisor_name: task_supervisor_name} = state
      ) do
    _ = Task.Supervisor.async_nolink(task_supervisor_name, fn ->
      count = ResolverHits.get(resolver_name) + 1
      ResolverHits.put(resolver_name, count)
      {:task_callback, count}
    end)

    {:noreply, state}
  end

  @impl true
  @spec handle_info({reference(), {:task_callback, any()}}, state()) :: {:noreply, state()}
  def handle_info({ref, {:task_callback, result}}, %{name: name} = state) do
    Logger.debug(
      "[#{inspect(name)}] Process #{inspect(ref)} finished with result #{inspect(result)}"
    )

    Process.demonitor(ref, [:flush])

    {:noreply, state}
  end

  @impl true
  @spec handle_info({:DOWN, reference(), :process, pid(), any()}, state()) :: {:noreply, state()}
  def handle_info({:DOWN, _ref, :process, _pid, reason}, %{name: name} = state) do
    Logger.debug("[#{inspect(name)}] Task failed with reason #{inspect(reason)}")

    {:noreply, state}
  end

  @spec config() :: %{counter_name: atom() | tuple()}
  defp config do
    Application.fetch_env!(:user_pref_web, :resolver_hits)
  end
end
