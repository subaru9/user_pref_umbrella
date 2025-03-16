defmodule UserPrefWeb.Schema.Mutation.MessageTest do
  use UserPrefWeb.ConnCase, async: true

  alias UserPref.Support.Fixtures
  alias Auth.Support.AuthHelper

  @create_message_doc """
  mutation createMessage($input: CreateMessageInput) {
    createMessage(input: $input) {
      id
      body
      chat {
        id
        topic
      }
      inserted_at
      user {
        id
      }
    }
  }
  """

  describe "@createMessage" do
    setup %{conn: conn} do
      user_a = Fixtures.user_fixture(%{id: 1})
      user_b = Fixtures.user_fixture(%{id: 2})
      chat = Fixtures.chat_fixture(%{user_a: user_a, user_b: user_b})

      token = AuthHelper.generate_token(user_a.id)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn, user_a: user_a, chat: chat}
    end

    test "message created", %{conn: conn, user_a: user_a, chat: chat} do
      expected_body = "blah"
      expected_user_id = to_string(user_a.id)
      expected_chat_id = to_string(chat.id)

      input_var = %{
        body: expected_body,
        chat_id: expected_chat_id
      }

      conn = post(conn, "/api", query: @create_message_doc, variables: %{"input" => input_var})

      %{
        "data" => %{
          "createMessage" => %{
            "body" => actual_body,
            "chat" => %{"id" => actual_chat_id},
            "id" => id,
            "user" => %{"id" => actual_user_id}
          }
        }
      } = json_response(conn, 200)

      assert id
      assert actual_body === expected_body
      assert actual_chat_id === expected_chat_id
      assert actual_user_id === expected_user_id
    end

    test "with invalid chat or user returns error", %{conn: conn, chat: chat} do
      input_var = %{
        body: "blah",
        chat_id: 42
      }

      conn = post(conn, "/api", query: @create_message_doc, variables: %{"input" => input_var})
      expected_code = "bad_request"

      %{
        "data" => %{"createMessage" => nil},
        "errors" => [
          %{
            "code" => actual_code
          }
        ]
      } = json_response(conn, 200)

      assert expected_code === actual_code
    end
  end
end
