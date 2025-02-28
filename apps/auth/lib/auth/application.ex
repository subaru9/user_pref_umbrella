defmodule Auth.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    %{cache_name: table_name, cache_opts: table_opts} = Auth.Config.tokens()
    SharedUtils.Cachable.ETS.init(name: table_name, opts: table_opts)

    children = [
      Auth.Tokens.Producer,
      Auth.Tokens.ConsumerSupervisor,
      {PrometheusTelemetry,
       exporter: [enabled?: false],
       metrics: [
         Auth.Tokens.Metrics.metrics()
       ]}
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
