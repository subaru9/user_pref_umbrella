defmodule Auth.Tokens.Producer do
  @moduledoc "Produce User events using cursor"

  use GenStage

  require Logger

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # 24 hours
  @interval 86_400_000

  def init(:ok) do
    Logger.debug("[#{__MODULE__}] init")
    schedule_next_run()

    {:producer, %{cursor: 0}}
  end

  def handle_info(:trigger, %{cursor: current_cursor}) do
    events = UserPref.users(%{first: 1000, order_by: :id})

    {:noreply, events, %{cursor: move_cursor(events, current_cursor)}}
  end

  def handle_demand(demand, %{cursor: current_cursor}) do
    if Auth.Config.debug() do
      Logger.debug("[#{__MODULE__}] received demand for #{inspect(demand)} users")
    end

    events = UserPref.users(%{after: current_cursor, limit: demand, order_by: :id})

    {:noreply, events, %{cursor: move_cursor(events, current_cursor)}}
  end

  defp schedule_next_run do
    Process.send_after(self(), :trigger, @interval)
  end

  defp move_cursor(events, current_cursor) do
    case List.last(events) do
      nil -> current_cursor
      %{id: id} -> id
    end
  end
end
