defmodule BgJobs.NodeStatus do
  @moduledoc """
  Generates metrics with per-node availability status 
  using Oban
  """

  alias BgJobs.NodeStatus.Metrics

  defdelegate update(), to: Metrics, as: :node_status_update
  defdelegate metrics(), to: Metrics

  def connected, do: [Node.self() | Node.list(:connected)]
end
