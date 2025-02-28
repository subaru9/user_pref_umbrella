defmodule Auth.Tokens.ConsumerSupervisor do
  use ConsumerSupervisor
  require Logger

  alias Auth.Tokens.Consumer
  alias Auth.Tokens.Producer

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Logger.debug("[#{__MODULE__}] init")

    children = [
      %{
        id: Consumer,
        start: {Consumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {Producer, min_demand: 5000, max_demand: 10_000}
        # {Auth.Tokens.Processor.via("auth_tokens_processor_1"), [min_demand: 500, max_demand: 1000]}
        # {Auth.Tokens.Processor.via("auth_tokens_processor_2"), []},
        # {Auth.Tokens.Processor.via("auth_tokens_processor_3"), []},
        # {Auth.Tokens.Processor.via("auth_tokens_processor_4"), []},
        # {Auth.Tokens.Processor.via("auth_tokens_processor_5"), []}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end

  def terminate(reason, _state) do
    Logger.warning("[#{__MODULE__}] ConsumerSupervisor terminated. Reason: #{inspect(reason)}")
    :ok
  end
end
