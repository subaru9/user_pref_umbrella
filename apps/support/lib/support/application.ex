defmodule Support.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Initialize Confispex with the schema
    Confispex.init(%{
      schema: Support.RuntimeSchema,
      context: %{
        env: Support.Config.current_env(),
        target: Support.Config.current_target()
      }
    })

    children = [
      # Starts a worker by calling: Support.Worker.start_link(arg)
      # {Support.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Support.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
