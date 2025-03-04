# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config, only: [config: 2, config: 3, import_config: 1, config_env: 0]

# Configure Mix tasks and generators

# Configure  sub-apps
config :user_pref,
  ecto_repos: [UserPref.Repo]

config :user_pref_web,
  ecto_repos: [UserPref.Repo],
  generators: [context_app: :user_pref]

config :bg_jobs,
  ecto_repos: [BgJobs.Repo]

config :auth, :tokens, %{
  cache_type: SharedUtils.Cachable.ETS,
  cache_name: :auth_token_cache,
  cache_opts: [:named_table, :public, read_concurrency: true, write_concurrency: true]
}

config :giphy_api,
  base_url: "https://api.giphy.com",
  search_limit: 20,
  pools: %{
    default: [
      protocols: [:http2],
      start_pool_metrics?: true
    ]
  }

config :user_pref_web, :resolver_hits, %{
  cache_type: SharedUtils.Cachable.GenServer,
  cache_name: {:global, UserPrefWeb.ResolverHits.Cache},
  counter_name: {:global, UserPrefWeb.ResolverHits.Counter}
}

# Configures the endpoint
config :user_pref_web, UserPrefWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: UserPrefWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UserPref.PubSub,
  live_view: [signing_salt: "sJa5Uczt"]

# Configure dependencies
config :libcluster,
  topologies: [
    # This strategy assumes that all nodes are on
    # the local host and can be discovered by epmd.
    epmd: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        timeout: 1000,
        hosts: [
          :user_pref_web@localhost,
          :user_pref@localhost,
          :bg_jobs@localhost
        ]
      ],
      list_nodes: {:erlang, :nodes, [:connected]}
    ]
  ]

config :request_cache_plug,
  enabled?: true,
  verbose?: true,
  graphql_paths: ["/api"],
  conn_priv_key: :__shared_request_cache__,
  request_cache_module: UserPrefWeb.RequestCache,
  default_ttl: :timer.hours(1),
  pool_opts: %{
    pool_name: :request_cache_pool,
    registration_scope: :local,
    pool_size: 10,
    max_overflow: 10
  }

config :ecto_shorts,
  repo: UserPref.Repo,
  error_module: EctoShorts.Actions.Error

config :bg_jobs, Oban,
  name: BgJobs.Oban,
  # Primary node for processing jobs
  peer: {Oban.Peers.Database, [leader?: true]},
  node: "bg_jobs@localhost",
  notifier: Oban.Notifiers.PG,
  repo: BgJobs.Repo,
  log: false,
  queues: [
    node_status: 1,
    user_avatars: 5
  ],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # run the worker every minute
       {"* * * * *", BgJobs.NodeStatus.Worker}
     ]},
    Oban.Plugins.Lifeline,
    Oban.Plugins.Reindexer,
    {Oban.Plugins.Pruner, max_age: :timer.hours(24)}
  ]

config :user_pref, Oban,
  name: UserPref.Oban,
  # failover node, processes jobs if primary node is down
  peer: {Oban.Peers.Database, [leader?: false]},
  node: "user_pref@localhost",
  notifier: Oban.Notifiers.PG,
  repo: BgJobs.Repo,
  log: false,
  queues: [
    node_status: 1,
    user_avatars: 5
  ],
  plugins: [
    Oban.Plugins.Lifeline,
    Oban.Plugins.Reindexer,
    {Oban.Plugins.Pruner, max_age: :timer.hours(24)}
  ]

config :user_pref_web, Oban,
  name: UserPrefWeb.Oban,
  # Never processes jobs, only enqueues them
  peer: false,
  node: "user_pref_web@localhost",
  notifier: Oban.Notifiers.PG,
  repo: BgJobs.Repo,
  log: false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  user_pref_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/user_pref_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  user_pref_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/user_pref_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
