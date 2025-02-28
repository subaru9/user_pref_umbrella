defmodule SharedUtils.Redis do
  @moduledoc """
  A unified interface for Redis operations, combining pooling and high-level commands.
  """

  alias SharedUtils.Redis.{Pool, Client}

  defdelegate child_spec(opts), to: Pool
  defdelegate execute_transaction(pool_name, command, on_success), to: Pool

  defdelegate put(pool_name, key, ttl, value), to: Client
  defdelegate get(pool_name, key), to: Client
  defdelegate delete(pool_name, key), to: Client
  defdelegate clear(pool_name), to: Client
end
