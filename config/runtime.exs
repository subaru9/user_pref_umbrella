import Config, only: [config: 2, config: 3, import_config: 1, config_env: 0, config_target: 0]

alias Confispex, as: Cfx

{:ok, _} = Application.ensure_all_started(:support)

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() === :prod do
  maybe_ipv6 = if Cfx.get("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :user_pref, UserPref.Repo,
    # ssl: true,
    url: Cfx.get("PRIMARY_DB_URL"),
    pool_size: Cfx.get("PRIMARY_DB_POOL_SIZE"),
    socket_options: maybe_ipv6

  config :bg_jobs, BgJobs.Repo,
    # ssl: true,
    url: Cfx.get("OBAN_DB_URL"),
    pool_size: Cfx.get("OBAN_DB_POOL_SIZE"),
    socket_options: maybe_ipv6

  import Config, only: [config: 2, config: 3, import_config: 1, config_env: 0]

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base = Cfx.get("SECRET_KEY_BASE")

  config :user_pref_web, UserPrefWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: Cfx.get("PORT")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :user_pref_web, UserPrefWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :user_pref_web, UserPrefWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :user_pref_web, UserPrefWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # config :user_pref, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")
end

config :auth, :tokens_runtime, %{
  ttl: Cfx.get("AUTH_TOKEN_TTL_SEC"),
  secret: Cfx.get("AUTH_TOKEN_SECRET"),
  debug: Cfx.get("AUTH_TOKEN_DEBUG")
}

config :giphy_api,
  api_key: Cfx.get("GIPHY_API_KEY"),
  pools: %{
    default: [
      size: Cfx.get("GIPHY_API_POOL_SIZE"),
      count: Cfx.get("GIPHY_API_POOL_COUNT")
    ]
  }
