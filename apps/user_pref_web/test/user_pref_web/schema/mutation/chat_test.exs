defmodule UserPrefWeb.Schema.Mutation.ChatTest do
  use UserPrefWeb.ConnCase, async: true

  alias UserPref.Support.Fixtures
  alias Auth.Support.AuthHelper

  @create_chat_doc """
  mutation createChat($input: CreateChatInput) {
    createChat(input: $input) {
      id
      topic
      inserted_at
      user_a {
        id
        first_name
        email
      }
      user_b {
        id
        first_name
        email
      }
    }
  }
  """

  describe "@createChat" do
    setup %{conn: conn} do
      user_a = Fixtures.user_fixture(%{id: 1})
      user_b = Fixtures.user_fixture(%{id: 2})

      token = AuthHelper.generate_token(user_a.id)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn, user_a: user_a, user_b: user_b}
    end

    test "chat created", %{conn: conn, user_a: user_a, user_b: user_b} do
      expected_topic = "blah"
      expected_user_a_id = user_a.id
      expected_user_b_id = user_b.id

      input_var = %{
        topic: expected_topic,
        user_b_id: expected_user_b_id
      }

      conn = post(conn, "/api", query: @create_chat_doc, variables: %{"input" => input_var})

      %{
        "data" => %{
          "createChat" => %{
            "id" => id,
            "topic" => actual_topic,
            "user_a" => %{
              "id" => actual_user_a_id
            },
            "user_b" => %{
              "id" => actual_user_b_id
            }
          }
        }
      } = json_response(conn, 200)

      assert id
      assert expected_topic === actual_topic
      assert expected_user_a_id === String.to_integer(actual_user_a_id)
      assert expected_user_b_id === String.to_integer(actual_user_b_id)
    end
  end
end
