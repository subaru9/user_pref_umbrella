defmodule UserPrefWeb.Schema.Query.UserPrefTest do
  use UserPrefWeb.ConnCase, async: true

  setup do
    users_params = [
      %{
        id: 1,
        first_name: "Bill",
        last_name: "Smith",
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
        last_name: "Johnson",
        email: "alice@gmail.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      },
      %{
        id: 3,
        first_name: "Jill",
        last_name: "Doe",
        email: "jill@hotmail.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: true,
          likes_faxes: false
        }
      },
      %{
        id: 4,
        first_name: "Tim",
        last_name: "Brown",
        email: "tim@gmail.com",
        pref: %{
          likes_emails: false,
          likes_phone_calls: false,
          likes_faxes: false
        },
        avatars: [%{title: "Tim Brown'd UserPic", url: "http://example.com", remote_id: "abc"}]
      }
    ]

    Enum.each(users_params, fn params ->
      UserPref.create_user(params)
    end)

    :ok
  end

  describe "@users" do
    test "users without prefs specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      assert length(json_response(conn, 200)["data"]["users"]) === 4
    end

    test "users with one pref specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(likesEmails: false) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      assert length(json_response(conn, 200)["data"]["users"]) === 2
    end

    test "users with two prefs specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(likesEmails: false, likesPhoneCalls: false) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      res = json_response(conn, 200)

      assert length(res["data"]["users"]) === 1
      pref = res["data"]["users"] |> hd() |> Map.get("pref")
      assert Map.get(pref, "likesEmails") === false
      assert Map.get(pref, "likesPhoneCalls") === false
    end

    test "users with all prefs specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(likesEmails: false, likesPhoneCalls: false, likesFaxes: false) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      assert length(json_response(conn, 200)["data"]["users"]) === 1
    end

    test "users with `first` specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(first: 2) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      res = json_response(conn, 200)
      assert length(res["data"]["users"]) === 2
      assert res["errors"] === nil
      assert res["data"]["users"] |> hd() |> Map.get("id") === "1"
      assert res["data"]["users"] |> List.last() |> Map.get("id") === "2"
    end

    test "users with `before` specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(before: 3) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      res = json_response(conn, 200)
      assert length(res["data"]["users"]) === 2
      assert res["errors"] === nil
      assert res["data"]["users"] |> hd() |> Map.get("id") === "1"
      assert res["data"]["users"] |> List.last() |> Map.get("id") === "2"
    end

    test "users with `after` specified", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { users(after: 2) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      res = json_response(conn, 200)
      assert length(res["data"]["users"]) === 2
      assert res["errors"] === nil
      assert res["data"]["users"] |> hd() |> Map.get("id") === "3"
      assert res["data"]["users"] |> List.last() |> Map.get("id") === "4"
    end

    test "fetches avatars", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query: "query { users { id email avatars { remote_id, url } } }"
        )

      res = json_response(conn, 200)
      assert length(res["data"]["users"] |> List.last() |> Map.get("avatars")) === 1
    end
  end

  describe "@user" do
    test "get a user by id", %{conn: conn} do
      user_id = 4

      conn =
        post(
          conn,
          "/api",
          query:
            "query { user(id: 4) { id avatars { remote_id} } }"
        )

      response = json_response(conn, 200)
      assert response["errors"] === nil
      assert response["data"]["user"]["id"] === "4"
      assert response["data"]["user"]["avatars"] |> hd() |> Map.get("remote_id") === "abc"
    end

    test "get a user by id with invalid id", %{conn: conn} do
      conn =
        post(
          conn,
          "/api",
          query:
            "query { user(id: 42) { id firstName lastName email pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      resp = json_response(conn, 200)
      assert resp["data"]["user"] === nil
      assert resp["errors"] |> hd() |> Map.get("details") === %{"id" => "42"}
      assert resp["errors"] |> hd() |> Map.get("message") === "not found"
    end

    test "get a user's auth token", %{conn: conn} do
      user_id = 1
      ttl = 86_400
      secret = "secret"
      token_data = {token, _exp} = Auth.Tokens.create(user_id, ttl, secret)
      Auth.Tokens.put(%{key: user_id, val: token_data})

      conn =
        post(
          conn,
          "/api",
          query:
            "query { user(id: 1) { id firstName lastName email authToken pref { likesEmails likesPhoneCalls likesFaxes } } }"
        )

      response = json_response(conn, 200)
      assert response["errors"] === nil
      assert response["data"]["user"]["id"] === "1"
      assert response["data"]["user"]["authToken"] === token
    end
  end
end
