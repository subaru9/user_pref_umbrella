defmodule UserPrefWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :user_pref_web,
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
      mod: {UserPrefWeb.Application, []},
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
      {:auth, in_umbrella: true},
      {:absinthe, "~> 1.7"},
      {:absinthe_phoenix, "~> 2.0"},
      {:absinthe_plug, "~> 1.5"},
      {:bandit, "~> 1.5"},
      {:bg_jobs, in_umbrella: true},
      {:esbuild, "~> 0.8", runtime: Mix.env() === :dev},
      {:giphy_api, in_umbrella: true},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.2"},
      {:libcluster, git: "https://github.com/bitwalker/libcluster.git"},
      {:local_cluster, "~> 2.0", only: [:test]},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:prometheus_telemetry, "~> 0.4"},
      {:request_cache_plug, "~> 1.0"},
      {:shared_utils, in_umbrella: true},
      {:singleton, "~> 1.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() === :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:user_pref, in_umbrella: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind user_pref_web", "esbuild user_pref_web"],
      "assets.deploy": [
        "tailwind user_pref_web --minify",
        "esbuild user_pref_web --minify",
        "phx.digest"
      ]
    ]
  end
end
