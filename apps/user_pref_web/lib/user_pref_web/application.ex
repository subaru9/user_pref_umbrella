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

      # Singleton supervisor for resolver hits counter
      {Singleton.Supervisor, name: UserPrefWeb.Singleton},
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

    # The singleton processes are colocated with resolvers 
    # to minimize in-node communication delays and simplify debugging and maintenance.
    start_resolver_hits_counter_as_global_process()
    start_resolver_hits_cache_as_global_process()

    {:ok, pid}
  end

  defp start_resolver_hits_counter_as_global_process do
    %{counter_name: {:global, local_name} = global_name} =
      Application.fetch_env!(:user_pref_web, :resolver_hits)

    {:ok, _pid} =
      Singleton.start_child(
        UserPrefWeb.Singleton,
        UserPrefWeb.ResolverHits.Counter,
        %{
          name: global_name,
          task_supervisor_name: {:global, UserPrefWeb.ResolverHits.TaskSupervisor}
        },
        local_name
      )
  end

  defp start_resolver_hits_cache_as_global_process do
    %{cache_name: {:global, local_name} = global_name, cache_type: cache_type} =
      Application.fetch_env!(:user_pref_web, :resolver_hits)

    {:ok, _pid} =
      Singleton.start_child(
        UserPrefWeb.Singleton,
        cache_type,
        [name: global_name],
        local_name
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
