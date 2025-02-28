defmodule UserPrefWeb.ResolverHits.Metrics do
  @moduledoc """
  Tracks durations and counts for cache `get` and `put` operations.
  """
  import Telemetry.Metrics, only: [counter: 2, distribution: 2]

  @prefix :resolver_hits
  @cache_get_duration [@prefix, :cache, :get, :duration]
  @cache_put_duration [@prefix, :cache, :put, :duration]
  @cache_put_count [@prefix, :cache, :put, :count]
  @nanosecond_buckets [
    100,
    500,
    1_000,
    2_000,
    3_000,
    4_000,
    5_000,
    6_000,
    7_000,
    8_000,
    9_000,
    10_000,
    20_000,
    50_000,
    100_000
  ]

  @cache_count %{count: 1}

  @spec metrics() :: list(Telemetry.Metrics.t())
  def metrics do
    [
      distribution(
        event_name(@cache_put_duration, :nanoseconds),
        event_name: @cache_put_duration,
        measurement: :duration,
        description: "Cache put duration",
        unit: :native,
        reporter_options: [buckets: @nanosecond_buckets],
        tags: [:cache_type, :cache_name, :key]
      ),
      distribution(
        event_name(@cache_get_duration, :nanoseconds),
        event_name: @cache_get_duration,
        measurement: :duration,
        description: "Cache get duration",
        unit: :native,
        reporter_options: [buckets: @nanosecond_buckets],
        tags: [:cache_type, :cache_name, :key]
      ),
      counter(
        event_name(@cache_put_count),
        event_name: @cache_put_count,
        description: "Cache puts count",
        measurement: :count,
        tags: [:cache_type, :cache_name, :key]
      )
    ]
  end

  @spec inc_cache_put(map()) :: :ok
  def inc_cache_put(metadata), do: execute(@cache_put_count, @cache_count, metadata)

  @spec cache_get_duration(non_neg_integer(), map()) :: :ok
  def cache_get_duration(duration, metadata),
    do: execute(@cache_get_duration, duration_measurement(duration), metadata)

  @spec cache_put_duration(non_neg_integer(), map()) :: :ok
  def cache_put_duration(duration, metadata),
    do: execute(@cache_put_duration, duration_measurement(duration), metadata)

  @spec execute([atom()], map(), map()) :: :ok
  def execute(event_name, measurements, metadata \\ %{}) do
    :telemetry.execute(
      event_name,
      measurements,
      metadata
    )
  end

  @spec event_name([atom()]) :: String.t()
  defp event_name(name), do: Enum.join(name, ".")

  @spec event_name([atom()], atom()) :: String.t()
  defp event_name(name, suffix), do: event_name(name ++ [suffix])

  @spec duration_measurement(non_neg_integer()) :: map()
  defp duration_measurement(duration), do: %{duration: duration}
end
