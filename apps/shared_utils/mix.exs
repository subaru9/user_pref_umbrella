defmodule SharedUtils.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :shared_utils,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:error_message, "~> 0.3.2",
       github: "subaru9/elixir_error_message",
       branch: "feat/json-serialisable-functions",
       override: true},
      {:poolboy, "~> 1.5"},
      {:redix, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
