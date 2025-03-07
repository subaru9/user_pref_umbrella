defmodule SharedUtils.Redis.ClientTest do
  use ExUnit.Case

  describe "&put/4" do
    setup do
      pool_name = :request_cache_pool
      on_exit(fn -> SharedUtils.Redis.clear(pool_name) end)
      [pool_name: pool_name]
    end

    test "with valid args stores value", %{pool_name: pool_name} do
      expected = "blah"
      key = :test_key

      :ok =
        SharedUtils.Redis.put(
          pool_name,
          key,
          10_000,
          expected
        )

      assert {:ok, expected} === SharedUtils.Redis.get(pool_name, key)
    end
  end

  describe "&delete/2" do
    setup do
      pool_name = :request_cache_pool
      on_exit(fn -> SharedUtils.Redis.clear(pool_name) end)
      [pool_name: pool_name]
    end

    test "with valid args deletes the value", %{pool_name: pool_name} do
      expected = nil
      value = "blah"
      key = :test_key

      :ok =
        SharedUtils.Redis.put(
          pool_name,
          key,
          10_000,
          value
        )

      {:ok, ^value} = SharedUtils.Redis.get(pool_name, key)
      :ok = SharedUtils.Redis.delete(pool_name, key)

      assert {:ok, expected} === SharedUtils.Redis.get(pool_name, key)
    end
  end
end
