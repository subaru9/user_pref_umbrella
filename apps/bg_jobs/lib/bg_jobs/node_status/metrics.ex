defmodule BgJobs.NodeStatus.Metrics do
  import Telemetry.Metrics, only: [last_value: 2]

  alias BgJobs.{Config, NodeStatus}

  @node_status [:node, :status, :update]

  @spec metrics() :: list(Telemetry.Metrics.t())
  def metrics do
    [
      last_value(
        event_name(@node_status),
        event_name: @node_status,
        measurement: :status,
        description: "Per-node availability",
        tags: [:node]
      )
    ]
  end

  def node_status_update do
    for node <- Config.configured_epmd_hosts() do
      status = if node in NodeStatus.connected(), do: 1, else: 0

      execute(
        @node_status,
        %{status: status},
        %{node: to_string(node)}
      )
    end

    :ok
  end

  @spec event_name([atom()]) :: String.t()
  defp event_name(name), do: Enum.join(name, ".")

  @spec execute([atom()], map(), map()) :: :ok
  defp execute(event_name, measurements, metadata) do
    :telemetry.execute(
      event_name,
      measurements,
      metadata
    )
  end
end
