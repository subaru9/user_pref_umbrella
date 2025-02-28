defmodule UserPrefWeb.Schema.Middleware.ResolverHitsCounter do
  @moduledoc """
  Increment counter on resolver hit
  """
  @behaviour Absinthe.Middleware
  alias UserPrefWeb.ResolverHits

  @impl true
  @spec call(Absinthe.Resolution.t(), term()) :: Absinthe.Resolution.t()
  def call(resolution, _opts) do
    field = resolution.definition.schema_node

    if resolver_func = extract_resolver_function(field) do
      resolver_func
      |> extract_resolver_name()
      |> ResolverHits.increment()
    end

    resolution
  end

  defp extract_resolver_function(%Absinthe.Type.Field{middleware: middleware}) do
    Enum.find_value(middleware, fn
      {{Absinthe.Resolution, :call}, resolver_function} ->
        resolver_function

      _ ->
        nil
    end)
  end

  defp extract_resolver_name(resolver_func) do
    resolver_func
    |> Function.info(:name)
    |> elem(1)
    |> Atom.to_string()
  end
end
