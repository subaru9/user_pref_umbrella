defmodule UserPref.Config do
  @app :user_pref

  def oban, do: Application.fetch_env!(@app, Oban)
  def cluster_topology, do: Application.fetch_env!(:libcluster, :topologies)
end
