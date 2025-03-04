import Config, only: [config: 2, config: 3]

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :user_pref, UserPref.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "user_pref_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :bg_jobs, BgJobs.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bg_jobs_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :user_pref_web, UserPrefWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jh8zdMBjGqsn8NomFTyc+BMNNLOWrUOtgpPjmK3LF+IN2h8J3C06j/E5WOqsOylI",
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :bg_jobs, Oban, testing: :inline
config :user_pref, Oban, testing: :inline

