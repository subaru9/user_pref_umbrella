defmodule Auth.Tokens.Metrics do
  @moduledoc """
  Custom metrics definitions
  """

  import Telemetry.Metrics, only: [counter: 2, distribution: 2]

  require Logger

  @event_prefix [:auth, :tokens]
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

  def metrics do
    [
      distribution(
        "#{metric_prefix()}.generation.time.nanoseconds",
        event_name: @event_prefix ++ [:generation],
        measurement: :time,
        description:
          "Tracks the distribution of auth token generation times (in nanoseconds), grouped into predefined buckets.",
        unit: :native,
        reporter_options: [buckets: @nanosecond_buckets],
        tags: [:source]
      ),
      counter(
        "#{metric_prefix()}.generation.count",
        event_name: @event_prefix ++ [:generation],
        measurement: :count,
        description: "Counts the total number of auth tokens generated.",
        tags: [:source]
      )
    ]
  end

  def emit_generation_time(time, source) do
    :telemetry.execute(
      @event_prefix ++ [:generation],
      %{time: time, count: 1},
      %{source: source}
    )

    if Auth.Config.debug() do
      Logger.debug("[#{source}] token generated in #{time} ns")
    end
  end

  def metric_prefix do
    Enum.join(@event_prefix, ".")
  end
end
