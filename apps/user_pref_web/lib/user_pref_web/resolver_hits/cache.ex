defmodule UserPrefWeb.ResolverHits.Cache do
  @moduledoc """
  A cache wrapper for the `resolver_hits` functionality.
  This module dynamically switches between different cache implementations
  based on the configuration and emits telemetry events for monitoring.
  """

  alias UserPrefWeb.ResolverHits.Metrics

  @spec get(key :: any()) :: any() | nil
  def get(key) do
    %{cache_type: type, cache_name: name} = config()
    start_time = System.monotonic_time()

    result = type.get(name, key) || 0

    duration = System.monotonic_time() - start_time
    metadata = %{cache_type: type, cache_name: inspect(name), key: key}
    Metrics.cache_get_duration(duration, metadata)

    result
  end

  @spec put(key :: any(), value :: any()) :: :ok
  def put(key, value) do
    %{cache_type: type, cache_name: name} = config()
    start_time = System.monotonic_time()

    result = type.put(name, key, value)

    duration = System.monotonic_time() - start_time
    metadata = %{cache_type: type, cache_name: inspect(name), key: key}
    Metrics.cache_put_duration(duration, metadata)
    Metrics.inc_cache_put(metadata)

    result
  end

  @spec delete(key :: any()) :: :ok
  def delete(key) do
    %{cache_type: type, cache_name: name} = config()
    type.delete(name, key)
  end

  @spec clear() :: :ok
  def clear do
    %{cache_type: type, cache_name: name} = config()
    type.clear(name)
  end

  @spec config() :: %{cache_type: module(), cache_name: atom()}
  defp config do
    Application.fetch_env!(:user_pref_web, :resolver_hits)
  end
end
