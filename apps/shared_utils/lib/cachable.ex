defmodule SharedUtils.Cachable do
  @moduledoc """
  A consistent interface for various caching mechanisms.
  """

  @callback get(name :: atom(), key :: any()) :: any() | nil
  @callback put(name :: atom(), key :: any(), value :: any()) :: :ok
  @callback delete(name :: atom(), key :: any()) :: :ok
  @callback clear(name :: atom()) :: :ok

  @optional_callbacks [clear: 1]
end
