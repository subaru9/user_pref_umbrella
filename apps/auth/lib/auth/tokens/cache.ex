defmodule Auth.Tokens.Cache do
  @moduledoc """
  A cache wrapper for the `auth_tokens` functionality.
  This module dynamically switches between different cache implementations
  based on the configuration.
  """

  @spec get(key :: any()) :: any() | nil
  def get(key) do
    %{cache_type: type, cache_name: name} = config()
    type.get(name, key)
  end

  @spec put(key :: any(), value :: any()) :: :ok
  def put(key, value) do
    %{cache_type: type, cache_name: name} = config()
    type.put(name, key, value)
  end

  @spec delete(key :: any()) :: :ok
  def delete(key) do
    %{cache_type: type, cache_name: name} = config()
    type.delete(name, key)
  end

  @spec clear() :: :ok
  def clear do
    %{cache_type: type, cache_name: name} = config()
    type.clear(name)
  end

  @spec config() :: %{cache_type: module(), cache_name: atom()}
  defp config do
    Auth.Config.tokens()
  end
end
