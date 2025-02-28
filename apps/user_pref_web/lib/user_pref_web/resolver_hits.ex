defmodule UserPrefWeb.ResolverHits do
  @moduledoc """
  Manages hits number by resolver name.
  """
  alias UserPrefWeb.ResolverHits.{Cache, Counter}

  @type counter_process_name :: atom() | tuple()
  @type resolver_name :: String.t()
  @type counter_val :: non_neg_integer()

  @spec increment(resolver_name()) :: :ok
  defdelegate increment(resolver_name), to: Counter

  @spec get(resolver_name()) :: counter_val()
  defdelegate get(resolver_name), to: Cache

  @spec put(resolver_name(), counter_val()) :: :ok
  defdelegate put(resolver_name, counter_val), to: Cache
end
