defmodule UserPrefWeb.Application do
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
         UserPrefWeb.Config.cluster_topology(),
         [name: UserPrefWeb.ClusterSupervisor]
       ]},

      # Oban
      {Oban, UserPrefWeb.Config.oban()},

      # Cache for api request with redis storage
      {Redix, name: :redis},
      {SharedUtils.Redis, UserPrefWeb.Config.request_cache_pool()},

      # DynamicSupervisor for singleton monitoring manager
      {Singleton.Supervisor, name: UserPrefWeb.SingletonManagerSupervisor},

      # HTTP endpoint
      UserPrefWeb.Endpoint,

      # Absinthe
      {Absinthe.Subscription, UserPrefWeb.Endpoint},

      # verious metrics
      UserPrefWeb.Telemetry,
      {
        PrometheusTelemetry,
        # by default exposed on 4050 port
        exporter: [enabled?: true],
        metrics: [
          PrometheusTelemetry.Metrics.Phoenix.metrics(),
          PrometheusTelemetry.Metrics.GraphQL.metrics(),
          PrometheusTelemetry.Metrics.VM.metrics(),
          RequestCache.Metrics.metrics(),
          UserPrefWeb.ResolverHits.Metrics.metrics()
        ]
      }
    ]

    opts = [strategy: :one_for_one, name: UserPrefWeb.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    # Starts singleton monitoring manager on each node, 
    # which monitors global singleton process ensures 
    # only one instance is running and is restarted as needed
    {:ok, _pid} = start_resolver_hits_counter_as_global_singleton()
    {:ok, _pid} = start_resolver_hits_cache_as_global_singleton()

    {:ok, pid}
  end

  defp start_resolver_hits_counter_as_global_singleton do
    Singleton.start_child(
      # Singleton manager supervisor name
      UserPrefWeb.SingletonManagerSupervisor,
      # Singleton process module
      UserPrefWeb.ResolverHits.Counter,
      # Args to be passed in on singleton process start
      %{
        name: UserPrefWeb.Config.resolver_hits_counter_global_name(),
        task_supervisor_name: {:global, UserPrefWeb.ResolverHits.TaskSupervisor}
      },
      # Name of the sigleton process to be made global (wrapped in {:global, name})
      UserPrefWeb.Config.resolver_hits_counter_local_name()
    )
  end

  defp start_resolver_hits_cache_as_global_singleton do
    Singleton.start_child(
      # Singleton manager supervisor name
      UserPrefWeb.SingletonManagerSupervisor,
      # Singleton process module
      UserPrefWeb.Config.resolver_hits_cache_type(),
      # Args to be passed in on singleton process start
      [name: UserPrefWeb.Config.resolver_hits_cache_global_name()],
      # Name of the sigleton process to be made global (wrapped in {:global, name})
      UserPrefWeb.Config.resolver_hits_cache_local_name()
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UserPrefWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
