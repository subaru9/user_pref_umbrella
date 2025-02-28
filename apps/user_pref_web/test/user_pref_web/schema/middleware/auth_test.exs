defmodule UserPrefWeb.Schema.Middleware.AuthTest do
  use UserPrefWeb.ConnCase, async: true
  alias GiphyApi.Support.TestHelpers

  @create_user_doc """
    mutation createUser($input: UserWithPrefInput) {
      createUser(input: $input) {
        id
        firstName
        lastName
        email
        pref {
          likesEmails
          likesPhoneCalls
          likesFaxes
        }
      }
    }
  """

  describe "Authorization checks" do
    setup %{conn: conn} do
      secret = Auth.Config.fetch_secret()
      # 1 hour from now
      exp = :os.system_time(:second) + 3600
      # example user_id with exp claim
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)

      first_name = "Jason"
      TestHelpers.mock_giphy_responses(first_name)

      {:ok,
       conn: put_req_header(conn, "authorization", "Bearer #{auth_token}"),
       first_name: first_name}
    end

    test "successful request with valid auth_token", %{conn: conn, first_name: first_name} do
      user_input_var = %{
        first_name: first_name,
        last_name: "Doe",
        email: "john_doe@example.com"
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{
          "createUser" => %{
            "id" => id,
            "email" => "john_doe@example.com"
          }
        }
      } = json_response(conn, 200)

      assert id !== nil
    end

    test "unauthorized error with invalid auth_token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Bearer invalid_token")

      user_input_var = %{
        email: "john_doe@example.com"
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{"createUser" => nil},
        "errors" => [
          %{
            "code" => code
          }
        ]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end

    test "unauthorized error when auth_token is missing", %{conn: conn} do
      conn = delete_req_header(conn, "authorization")

      user_input_var = %{
        email: "john_doe@example.com"
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{"createUser" => nil},
        "errors" => [
          %{
            "code" => code
          }
        ]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end

    test "unauthorized error when auth_token is expired", %{conn: conn} do
      # Create an expired token
      secret = Auth.Config.fetch_secret()
      # 1 hour in the past
      exp = :os.system_time(:second) - 3600
      payload = %{"sub" => 1, "exp" => exp}
      expired_token = Auth.Token.create(payload, secret)

      conn = put_req_header(conn, "authorization", "Bearer #{expired_token}")

      user_input_var = %{
        email: "john_doe@example.com"
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{"createUser" => nil},
        "errors" => [
          %{
            "code" => code
          }
        ]
      } = json_response(conn, 200)

      assert code === "unauthorized"
    end
  end
end
