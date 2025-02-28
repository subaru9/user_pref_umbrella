defmodule UserPrefWeb.Schema.Query.ResolverHitsCounterTest do
  use UserPrefWeb.ConnCase

  @number_of_hits 1
  @users_doc "query { users { id } }"
  @resolver_hits_doc "query { resolverHits(key: \"users\") }"

  describe "@resolverHits with singleton genserver cache" do
    setup do
      UserPrefWeb.ResolverHits.Cache.clear()
      :ok
    end

    @tag timeout: :infinity
    test "resolver hits counted correctly with singleton genserver cache", %{conn: conn} do
      conn = make_queries(conn, @users_doc, @number_of_hits)
      conn = post(conn, "/api", query: @resolver_hits_doc)
      assert json_response(conn, 200)["data"]["resolverHits"] === @number_of_hits

      %{cache_name: {:global, local_name} = _global_name} =
        Application.fetch_env!(:user_pref_web, :resolver_hits)

      cache_pid = :global.whereis_name(local_name)
      assert :sys.get_state(cache_pid) === %{"users" => @number_of_hits}
      assert UserPrefWeb.ResolverHits.get("users") === @number_of_hits
    end
  end

  describe "@resolverHits with Agent cache" do
    setup do
      cache_type = SharedUtils.Cachable.Agent
      cache_name = UserPrefWeb.ResolverHits.TestCache
      counter_name = UserPrefWeb.ResolverHits.TestCounter

      Application.put_env(:user_pref_web, :resolver_hits, %{
        cache_type: cache_type,
        cache_name: cache_name,
        counter_name: counter_name
      })

      {:ok, _pid} = SharedUtils.Cachable.Agent.start_link(name: cache_name)

      {:ok, _pid} =
        UserPrefWeb.ResolverHits.Counter.start_link(
          name: counter_name,
          task_supervisor_name: UserPrefWeb.ResolverHits.TestTaskSuprevisor
        )

      UserPrefWeb.ResolverHits.Cache.clear()
      :ok
    end

    @tag timeout: :infinity
    test "resolver hits counted correctly with Agent cache", %{conn: conn} do
      conn = make_queries(conn, @users_doc, @number_of_hits)
      conn = post(conn, "/api", query: @resolver_hits_doc)
      assert json_response(conn, 200)["data"]["resolverHits"] === @number_of_hits
      assert :sys.get_state(UserPrefWeb.ResolverHits.TestCache) === %{"users" => @number_of_hits}
      assert UserPrefWeb.ResolverHits.get("users") === @number_of_hits
      UserPrefWeb.ResolverHits.Cache.clear()
    end
  end

  describe "@resolverHits with ETS cache" do
    setup do
      Application.put_env(:user_pref_web, :resolver_hits, %{
        cache_type: SharedUtils.Cachable.ETS,
        cache_name: :resolver_hits_cache,
        cache_opts: [:named_table, :public, read_concurrency: true],
        counter_name: UserPrefWeb.ResolverHits.TestCounter
      })

      SharedUtils.Cachable.ETS.init(
        name: :resolver_hits_cache,
        opts: [:named_table, :public, read_concurrency: true]
      )

      {:ok, _pid} =
        UserPrefWeb.ResolverHits.Counter.start_link(
          name: UserPrefWeb.ResolverHits.TestCounter,
          task_supervisor_name: UserPrefWeb.ResolverHits.TestTaskSuprevisor
        )

      UserPrefWeb.ResolverHits.Cache.clear()

      :ok
    end

    @tag timeout: :infinity
    test "resolver hits counted correctly", %{conn: conn} do
      conn = make_queries(conn, @users_doc, @number_of_hits)
      conn = post(conn, "/api", query: @resolver_hits_doc)
      assert json_response(conn, 200)["data"]["resolverHits"] === @number_of_hits
      assert SharedUtils.Cachable.ETS.get(:resolver_hits_cache, "users") === @number_of_hits
      assert UserPrefWeb.ResolverHits.get("users") === @number_of_hits
    end
  end

  defp make_queries(conn, query, times) do
    Enum.reduce(1..times, conn, fn _, conn -> post(conn, "/api", query: query) end)
  end
end
