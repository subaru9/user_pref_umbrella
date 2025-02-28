defmodule UserPref.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UserPref.Repo,
      # Cluster Supervisor
      {Cluster.Supervisor,
       [
         UserPref.Config.cluster_topology(),
         [name: UserPref.ClusterSupervisor]
       ]},
      {Oban, UserPref.Config.oban()},
      {DNSCluster, query: Application.get_env(:user_pref, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UserPref.PubSub},
      {PrometheusTelemetry,
       exporter: [enabled?: false],
       metrics: [
         PrometheusTelemetry.Metrics.Ecto.metrics_for_repo(UserPref.Repo)
       ]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: UserPref.Supervisor)
  end
end
