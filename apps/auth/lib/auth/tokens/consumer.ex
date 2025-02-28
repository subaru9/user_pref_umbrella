defmodule Auth.Tokens.Consumer do
  @moduledoc """
  Stores refreshed token in cache
  """
  require Logger

  alias Auth.Tokens
  alias Auth.Tokens.Metrics

  def start_link(%{id: user_id}) do
    Task.start_link(fn ->
      config = Auth.Config.tokens()

      start_time = System.monotonic_time()
      token_map = Tokens.refresh(user_id, config)

      if token_map do
        Tokens.put(token_map)
        generation_duration = System.monotonic_time() - start_time
        Metrics.emit_generation_time(generation_duration, __MODULE__)
      end

      if Auth.Config.debug() do
        Logger.debug("[#{__MODULE__}] Stored token for user #{user_id}")
      end
    end)
  end
end
