defmodule UserPrefWeb.Schema.Mutation.UserPrefTest do
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

  describe "@createUser" do
    setup %{conn: conn} do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) + 3600
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token}")
      {:ok, conn: conn}
    end

    test "user created", %{conn: conn} do
      first_name = "John"

      user_input_var = %{
        first_name: first_name,
        last_name: "Doe",
        email: "john_doe@gmail.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }

      TestHelpers.mock_giphy_responses(first_name)
      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{
          "createUser" => %{
            "email" => email,
            "id" => id,
            "firstName" => first_name,
            "lastName" => last_name,
            "pref" => %{
              "likesEmails" => true,
              "likesFaxes" => true,
              "likesPhoneCalls" => false
            }
          }
        }
      } = json_response(conn, 200)

      assert id
      assert email === "john_doe@gmail.com"
      assert first_name === "John"
      assert last_name === "Doe"
      # Fetch user with avatars
      conn =
        post(conn, "/api",
          query: "query($id: ID!) { user(id: $id) { id email avatars { remote_id, url } } }",
          variables: %{"id" => id}
        )

      response = json_response(conn, 200)
      assert response["errors"] === nil
      assert response["data"]["user"]["id"] === id

      avatars = response["data"]["user"]["avatars"]
      assert length(avatars) > 0

      Enum.each(avatars, fn avatar ->
        assert is_binary(avatar["remote_id"])
        assert is_binary(avatar["url"])
      end)
    end
  end

  @update_user_doc """
  mutation {
    updateUser(input: { id: 1, firstName: "John", lastName: "Doe", email: "john_doe@example.com" }) {
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

  describe "@updateUser" do
    setup %{conn: conn} do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) + 3600
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token}")
      {:ok, conn: conn}
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

    test "updates user", %{conn: conn, original_user: original_user} do
      conn = post(conn, "/api", query: @update_user_doc)
      resp = json_response(conn, 200)
      updated_user_data = resp["data"]["updateUser"]

      assert updated_user_data["id"] === Integer.to_string(original_user.id)
      assert updated_user_data["firstName"] !== original_user.first_name
      assert updated_user_data["lastName"] !== original_user.last_name
      assert updated_user_data["email"] !== original_user.email
    end
  end
end
