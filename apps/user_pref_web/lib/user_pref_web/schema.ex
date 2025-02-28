defmodule UserPrefWeb.Schema do
  @moduledoc """
    The main schema for the application
  """
  use Absinthe.Schema

  alias UserPrefWeb.Schema
  alias UserPrefWeb.Schema.Middleware

  import_types Schema.Type.UserPref
  import_types Schema.Query.UserPref
  import_types Schema.Mutation.UserPref
  import_types Schema.Subscription.UserPref
  import_types Schema.Query.ResolverHitsCounter

  query do
    import_fields :user_queries
    import_fields :resolver_hits_counter_query
  end

  mutation do
    import_fields :user_mutations
    import_fields :pref_mutations
  end

  subscription do
    import_fields :user_subscriptions
  end

  def middleware(middleware, field, object) do
    middleware
    |> apply(:auth, field, object)
    |> apply(:error_handler, field, object)
    |> apply(:debug, field, object)
    |> apply(:request_cache, field, object)
    |> apply(:resolver_hits_counter, field, object)
  end

  defp apply(middleware, :request_cache, _field, object) do
    case object do
      %{identifier: :query} ->
        test_ttl = if Mix.env() === :test, do: :timer.seconds(1), else: nil
        opts = if test_ttl, do: [ttl: test_ttl], else: []
        middleware ++ [{RequestCache.Middleware, opts}]

      _ ->
        middleware
    end
  end

  defp apply(middleware, :auth, _field, object) do
    case object do
      %{identifier: :mutation} ->
        [{Middleware.Auth, []}] ++ middleware

      _ ->
        middleware
    end
  end

  defp apply(middleware, :error_handler, _field, _object) do
    middleware ++ [{Middleware.ErrorHandler, []}]
  end

  defp apply(middleware, :debug, _field, _object) do
    if System.get_env("DEBUG") do
      [{Middleware.Debug, :start}] ++ middleware
    else
      middleware
    end
  end

  defp apply(middleware, :resolver_hits_counter, _field, _object) do
    middleware ++ [{Middleware.ResolverHitsCounter, []}]
  end

  @doc """
  Initializes the GraphQL execution context with a Dataloader instance.

  - Instantiates a new `Dataloader`.
  - Registers the `UserPref` source (`UserPref.datasource()`) for batch-loading associations.
  - Injects `Dataloader` into the Absinthe context (`ctx`), making it available to resolvers.

  Resolvers using `dataloader(UserPref)` depend on this setup to batch and efficiently load associations.
  """
  def context(ctx) do
    loader =
      Dataloader.add_source(Dataloader.new(), UserPref, UserPref.datasource())

    Map.put(ctx, :loader, loader)
  end

  @doc """
  Registers Absinthe's Dataloader middleware.

  - Ensures `Dataloader` is automatically applied when resolving fields.
  - Adds `Absinthe.Middleware.Dataloader` to Absinthe's middleware stack.

  Without this, `Dataloader` won’t optimize batch queries, leading to inefficient database access.
  """
  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
