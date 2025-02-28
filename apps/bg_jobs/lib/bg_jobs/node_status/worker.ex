defmodule BgJobs.NodeStatus.Worker do
  use Oban.Worker,
    queue: :node_status,
    unique: [period: 60, states: BgJobs.in_progress_states()]

  @impl Oban.Worker
  def perform(_job), do: BgJobs.NodeStatus.update()
end
