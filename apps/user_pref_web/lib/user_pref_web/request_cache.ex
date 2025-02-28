defmodule UserPrefWeb.RequestCache do
  @moduledoc """
  A wrapper around `SharedUtils.Cachable.Redis` for managing 
  request-level caching in the `UserPrefWeb` application.
  """

  alias SharedUtils.Redis
  alias UserPrefWeb.Config

  @type key :: String.t()
  @type ttl :: integer()
  @type value :: any()
  @type error :: {:error, ErrorMessage.t()}

  @spec put(key, ttl, value) :: :ok | error
  def put(key, ttl, value) do
    Redis.put(pool_name(), key, ttl, value)
  end

  @spec get(key) :: {:ok, value} | error
  def get(key) do
    Redis.get(pool_name(), key)
  end

  @spec clear() :: :ok | error
  def clear do
    Redis.clear(pool_name())
  end

  defp pool_name do
    Map.fetch!(Config.request_cache_pool(), :pool_name)
  end
end
