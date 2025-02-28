defmodule UserPrefWeb.RequestCacheTest do
  use UserPrefWeb.ConnCase, async: true

  setup do
    # Ensure Redis is cleared even if a test fails or errors out
    on_exit(fn ->
      UserPrefWeb.RequestCache.clear()
    end)

    users_params = [
      %{
        id: 1,
        first_name: "Bill",
        last_name: "Doe",
        email: "bill@gmail.com",
        pref: %{
          likes_emails: false,
          likes_phone_calls: true,
          likes_faxes: true
        }
      },
      %{
        id: 2,
        first_name: "Alice",
        last_name: "Smith",
        email: "alice@gmail.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }
    ]

    Enum.each(users_params, fn params ->
      UserPref.create_user(params)
    end)

    :ok
  end

  describe "Request Cache Verification" do
    test "cache hit for identical queries", %{conn: conn} do
      query = "{ user(id: 1) { id firstName lastName email } }"

      conn1 = get(conn, "/api", query: query)
      assert json_response(conn1, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn1, "rc-cache-status") === []

      conn2 = get(conn, "/api", query: query)
      assert json_response(conn2, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn2, "rc-cache-status") === ["HIT"]
    end

    test "cache miss for different queries", %{conn: conn} do
      query1 = "{ user(id: 1) { id firstName lastName email } }"
      query2 = "{ user(id: 2) { id firstName lastName email } }"

      conn1 = get(conn, "/api", query: query1)
      assert json_response(conn1, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn1, "rc-cache-status") === []

      conn2 = get(conn, "/api", query: query2)
      assert json_response(conn2, 200)["data"]["user"]["id"] === "2"
      assert get_resp_header(conn2, "rc-cache-status") === []
    end

    test "cache expires after TTL", %{conn: conn} do
      query = "{ user(id: 1) { id firstName lastName email } }"

      conn1 = get(conn, "/api", query: query)
      assert json_response(conn1, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn1, "rc-cache-status") === []

      conn2 = get(conn, "/api", query: query)
      assert json_response(conn2, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn2, "rc-cache-status") === ["HIT"]

      :timer.sleep(1100)

      conn3 = get(conn, "/api", query: query)
      assert json_response(conn3, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn3, "rc-cache-status") === []
    end

    test "graceful handling of cache errors", %{conn: conn} do
      :ok = Application.stop(:redix)

      query = "{ user(id: 1) { id firstName lastName email } }"

      conn = get(conn, "/api", query: query)
      assert json_response(conn, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn, "rc-cache-status") === []
    end

    test "cache bypass for invalid queries", %{conn: conn} do
      invalid_query = "{ user(id: }"

      conn = get(conn, "/api", query: invalid_query)
      assert json_response(conn, 200)["errors"] !== nil

      valid_query = "{ user(id: 1) { id firstName lastName email } }"
      conn2 = get(conn, "/api", query: valid_query)
      assert json_response(conn2, 200)["data"]["user"]["id"] === "1"
      assert get_resp_header(conn2, "rc-cache-status") === []
    end
  end
end
