defmodule UserPrefWeb.Schema.Middleware.ErrorHandlerTest do
  use UserPrefWeb.ConnCase, async: true

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

  describe "Handling errors" do
    setup %{conn: conn} do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) + 3600
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token}")
      {:ok, conn: conn}
    end

    test "conflict error returned on email duplication", %{conn: conn} do
      Fixtures.user_fixture(%{email: "syber@junkie.com"})

      user_input_var = %{
        first_name: "John",
        last_name: "Doe",
        email: "syber@junkie.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{
          "createUser" => nil
        },
        "errors" => [
          %{
            "code" => code,
            "details" => details,
            "message" => message
          }
        ]
      } = json_response(conn, 200)

      assert code === "conflict"
      assert details === %{"email" => "has already been taken"}
      assert message === "email has already been taken"
    end

    test "error with bad_request code returned when first_name is missing", %{conn: conn} do
      user_input_var = %{
        last_name: "Doe",
        email: "john_doe@example.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{
          "createUser" => nil
        },
        "errors" => [
          %{
            "code" => code,
            "details" => details,
            "message" => message
          }
        ]
      } = json_response(conn, 200)

      assert code === "bad_request"
      assert details === %{"first_name" => "can't be blank"}
      assert message === "first_name can't be blank"
    end

    test "error with bad_request code returned when last_name is missing", %{conn: conn} do
      user_input_var = %{
        first_name: "John",
        email: "john_doe@example.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }

      conn = post(conn, "/api", query: @create_user_doc, variables: %{"input" => user_input_var})

      %{
        "data" => %{
          "createUser" => nil
        },
        "errors" => [
          %{
            "code" => code,
            "details" => details,
            "message" => message
          }
        ]
      } = json_response(conn, 200)

      assert code === "bad_request"
      assert details === %{"last_name" => "can't be blank"}
      assert message === "last_name can't be blank"
    end
  end
end
