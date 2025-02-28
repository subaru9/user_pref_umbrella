defmodule UserPrefWeb.Schema.Query.ResolverHitsCounter do
  @moduledoc """
  Queries for the ResolverHitsCounter
  """
  use Absinthe.Schema.Notation

  object :resolver_hits_counter_query do
    @desc "Query for viewing a resolvers hits"
    field :resolver_hits, :integer do
      arg :key, :string

      resolve fn %{key: resolver_name}, _ ->
        hits = UserPrefWeb.ResolverHits.get(resolver_name)
        {:ok, hits}
      end
    end
  end
end
