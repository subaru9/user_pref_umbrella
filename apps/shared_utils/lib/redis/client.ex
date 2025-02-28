defmodule SharedUtils.Redis.Client do
  @moduledoc """
  An interface for caching data in Redis with `poolboy` connection pooling.

  ### Error Handling

  Errors from Redis are converted into structured error tuples using `SharedUtils.ErrorConverter`.

  ### Example Usage

  ```elixir
  :ok = SharedUtils.Cachable.Redis.put(:my_redis_pool, "my_key", 3600, %{value: "some data"})
  {:ok, value} = SharedUtils.Cachable.Redis.get(:my_redis_pool, "my_key")
  ```
  """

  require Logger

  @type pool_name :: atom()
  @type key :: String.t()
  @type ttl :: integer()
  @type value :: any()
  @type error :: {:error, ErrorMessage.t()}


  alias SharedUtils.Redis

  @spec put(pool_name, key, ttl, value) :: :ok | error
  def put(pool_name, key, ttl, value) do
    serialized_value = :erlang.term_to_binary(value)

    command =
      if ttl do
        ["SETEX", key, ms_to_sec(ttl), serialized_value]
      else
        ["SET", key, serialized_value]
      end

    Redis.execute_transaction(pool_name, command, fn _response ->
      Logger.debug("[#{__MODULE__}] Storing key=#{key}, ttl=#{ttl}, value=#{inspect(value)}")
      :ok
    end)
  end

  @spec get(pool_name, key) :: {:ok, value} | error
  def get(pool_name, key) do
    Logger.debug("[#{__MODULE__}] Fetching key=#{key}")

    Redis.execute_transaction(pool_name, ["GET", key], fn
      value when is_binary(value) -> {:ok, :erlang.binary_to_term(value)}
      value -> {:ok, value}
    end)
  end

  @spec delete(pool_name, key) :: :ok | error
  def delete(pool_name, key) do
    Redis.execute_transaction(pool_name, ["DEL", key], fn _response ->
      Logger.debug("[#{__MODULE__}] Deleting key=#{key}")
      :ok
    end)
  end

  @spec clear(pool_name) :: :ok | error
  def clear(pool_name) do
    Redis.execute_transaction(pool_name, ["FLUSHDB"], fn _response ->
      Logger.debug("[#{__MODULE__}] Clearing the entire Redis database")
      :ok
    end)
  end

  defp ms_to_sec(ttl_ms), do: div(ttl_ms, 1000)
end
