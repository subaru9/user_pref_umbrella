defmodule BgJobs.Config do
  @app :bg_jobs

  def oban, do: Application.fetch_env!(@app, Oban)
  def cluster_topology, do: Application.fetch_env!(:libcluster, :topologies)

  def configured_epmd_hosts do
    cluster_topology()
    |> Keyword.fetch!(:epmd)
    |> Keyword.fetch!(:config)
    |> Keyword.fetch!(:hosts)
  end
end
