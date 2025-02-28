defmodule UserPref.MixProject do
  use Mix.Project

  def project do
    [
      app: :user_pref,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {UserPref.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dataloader, "~> 1.0.0"},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_shorts,
       git: "https://github.com/subaru9/ecto_shorts.git",
       branch: "feat/query-builder-in-context",
       override: true},
      {:ecto_sql, "~> 3.10"},
      {:error_message,
       git: "https://github.com/subaru9/elixir_error_message.git",
       branch: "feat/json-serialisable-functions",
       override: true},
      {:jason, "~> 1.2"},
      {:libcluster, git: "https://github.com/bitwalker/libcluster.git"},
      {:oban, "~> 2.19"},
      {:prometheus_telemetry, "~> 0.4"},
      {:phoenix_pubsub, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:sandbox_registry, "~> 0.1"},
      {:shared_utils, in_umbrella: true},
      {:singleton, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run #{__DIR__}/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
