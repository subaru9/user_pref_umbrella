defmodule GiphyApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: GiphyApiFinch, pools: GiphyApi.Config.pools!()},
      {Task.Supervisor, name: GiphyApi.TaskSupervisor},
      {PrometheusTelemetry,
       metrics: [
         PrometheusTelemetry.Metrics.Finch.metrics()
       ]}

      # Starts a worker by calling: GiphyApi.Worker.start_link(arg)
      # {GiphyApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GiphyApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
