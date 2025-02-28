defmodule GiphyApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :giphy_api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(env) when env in [:test, :dev], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GiphyApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:error_message,
       git: "https://github.com/subaru9/elixir_error_message.git",
       branch: "feat/json-serialisable-functions",
       override: true},
      {:finch, "~> 0.19"},
      {:prometheus_telemetry, "~> 0.4"},
      {:sandbox_registry, "~> 0.1"},
      {:shared_utils, in_umbrella: true}
    ]
  end
end
