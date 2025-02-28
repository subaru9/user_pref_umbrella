defmodule BgJobs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Cluster Supervisor
      {Cluster.Supervisor,
       [
         BgJobs.Config.cluster_topology(),
         [name: BgJobs.ClusterSupervisor]
       ]},

      # Oban
      {Oban, BgJobs.Config.oban()},
      {PrometheusTelemetry,
       exporter: [enabled?: false],
       metrics: [
         PrometheusTelemetry.Metrics.Oban.metrics(),
         BgJobs.NodeStatus.metrics()
       ]}
      # Starts a worker by calling: BgJobs.Worker.start_link(arg)
      # {BgJobs.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BgJobs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
