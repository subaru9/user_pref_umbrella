defmodule UserPrefWeb.Schema.Middleware.AuthTest do
  use UserPrefWeb.ConnCase, async: true
  alias GiphyApi.Support.TestHelpers

  @update_user_doc """
    mutation updateUser($input: UserInput) {
      updateUser(input: $input) {
        id
        firstName
        lastName
        email
      }
    }
  """

  describe "Authorization checks" do
    setup %{conn: conn} do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) + 3600
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)

      first_name = "Jason"
      TestHelpers.mock_giphy_responses(first_name)

      {:ok,
       conn: put_req_header(conn, "authorization", "Bearer #{auth_token}"), first_name: first_name}
    end

    setup do
      params = %{
        id: 1,
        first_name: "Bill",
        last_name: "Smith",
        email: "bill@gmail.com",
        pref: %{
          likes_emails: false,
          likes_phone_calls: true,
          likes_faxes: true
        }
      }

      [original_user: Fixtures.user_fixture(params)]
    end

    test "successful request with valid auth_token", %{conn: conn, original_user: original_user} do
      updated_user_input = %{
        id: original_user.id,
        first_name: "Updated",
        last_name: "User",
        email: "updated_user@example.com"
      }

      conn = post(conn, "/api", query: @update_user_doc, variables: %{"input" => updated_user_input})

      %{
        "data" => %{
          "updateUser" => %{
            "id" => id,
            "firstName" => "Updated",
            "lastName" => "User",
            "email" => "updated_user@example.com"
          }
        }
      } = json_response(conn, 200)

      assert id === Integer.to_string(original_user.id)
    end

    test "unauthorized error with invalid auth_token", %{conn: conn, original_user: original_user} do
      conn = put_req_header(conn, "authorization", "Bearer invalid_token")

      updated_user_input = %{
        id: original_user.id,
        email: "updated_user@example.com"
      }

      conn = post(conn, "/api", query: @update_user_doc, variables: %{"input" => updated_user_input})

      %{
        "data" => %{"updateUser" => nil},
        "errors" => [%{"code" => code}]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end

    test "unauthorized error when auth_token is missing", %{conn: conn, original_user: original_user} do
      conn = delete_req_header(conn, "authorization")

      updated_user_input = %{
        id: original_user.id,
        email: "updated_user@example.com"
      }

      conn = post(conn, "/api", query: @update_user_doc, variables: %{"input" => updated_user_input})

      %{
        "data" => %{"updateUser" => nil},
        "errors" => [%{"code" => code}]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end

    test "unauthorized error when auth_token is expired", %{conn: conn, original_user: original_user} do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) - 3600
      payload = %{"sub" => 1, "exp" => exp}
      expired_token = Auth.Token.create(payload, secret)

      conn = put_req_header(conn, "authorization", "Bearer #{expired_token}")

      updated_user_input = %{
        id: original_user.id,
        email: "updated_user@example.com"
      }

      conn = post(conn, "/api", query: @update_user_doc, variables: %{"input" => updated_user_input})

      %{
        "data" => %{"updateUser" => nil},
        "errors" => [%{"code" => code}]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end
  end
end
