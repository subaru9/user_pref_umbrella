defmodule UserPrefWeb.Config do
  @app :user_pref_web

  def oban, do: Application.fetch_env!(@app, Oban)

  def request_cache_pool,
    do: Application.fetch_env!(:request_cache_plug, :pool_opts)

  def cluster_topology, do: Application.fetch_env!(:libcluster, :topologies)
end
