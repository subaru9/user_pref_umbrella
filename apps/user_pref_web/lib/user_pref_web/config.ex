defmodule UserPrefWeb.Config do
  @app :user_pref_web

  @spec oban :: keyword
  def oban, do: Application.fetch_env!(@app, Oban)

  @spec request_cache_pool :: map
  def request_cache_pool, do: Application.fetch_env!(:request_cache_plug, :pool_opts)

  @spec cluster_topology :: map
  def cluster_topology, do: Application.fetch_env!(:libcluster, :topologies)

  @spec resolver_hits_counter_global_name :: {:global, atom}
  def resolver_hits_counter_global_name do
    @app
    |> Application.fetch_env!(:resolver_hits)
    |> Map.fetch!(:counter_name)
  end

  @spec resolver_hits_counter_local_name :: atom
  def resolver_hits_counter_local_name do
    {:global, local_name} = resolver_hits_counter_global_name()
    local_name
  end

  @spec resolver_hits_cache_global_name :: {:global, atom}
  def resolver_hits_cache_global_name do
    @app
    |> Application.fetch_env!(:resolver_hits)
    |> Map.fetch!(:cache_name)
  end

  @spec resolver_hits_cache_local_name :: atom
  def resolver_hits_cache_local_name do
    {:global, local_name} = resolver_hits_cache_global_name()
    local_name
  end

  @spec resolver_hits_cache_type :: atom
  def resolver_hits_cache_type do
    @app
    |> Application.fetch_env!(:resolver_hits)
    |> Map.fetch!(:cache_type)
  end
  
  def current_env, do: Application.fetch_env!(@app, :env)
end
