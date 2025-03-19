defmodule UserPrefWeb.Schema.Query.ChatTest do
  use UserPrefWeb.ConnCase, async: true

  @history_doc """
  query chatHistory($input: ChatHistoryInput!) {
    chatHistory(input: $input) {
      id
      body
      user { id }
      chat { id }
    }
  }
  """

  describe "@history" do
    setup %{conn: conn} do
      user1 = user_fixture(%{id: 1})
      user2 = user_fixture(%{id: 2})
      chat = chat_fixture(%{user_a: user1, user_b: user2})
      msg1 = message_fixture(%{id: 1, chat: chat, user: user1, body: "a user_a"})
      msg2 = message_fixture(%{id: 2, chat: chat, user: user2, body: "b user_b"})
      msg3 = message_fixture(%{id: 3, chat: chat, user: user2, body: "c user_b"})
      msg4 = message_fixture(%{id: 4, chat: chat, user: user1, body: "d user_a"})

      [conn: conn, chat: chat, msg1: msg1, msg2: msg2, msg3: msg3, msg4: msg4]
    end

    test "to return last several messages including the last one as the first butch in pagination",
         %{
           conn: conn,
           chat: chat,
           msg3: msg3,
           msg4: msg4
         } do
      input = %{chat_id: chat.id, last: 2}
      conn = post(conn, "/api", query: @history_doc, variables: %{"input" => input})
      expected = [msg3.body, msg4.body]

      actual =
        conn
        |> json_response(200)
        |> get_in(["data", "chatHistory"])
        |> Enum.map(&Map.get(&1, "body"))

      assert expected === actual
    end

    test "to return messages before the last alredy received using cursor (reverse pagination)",
         %{
           conn: conn,
           chat: chat,
           msg2: msg2,
           msg1: msg1
         } do
      input = %{chat_id: chat.id, last: 2, cursor: 3}
      conn = post(conn, "/api", query: @history_doc, variables: %{"input" => input})
      expected = [msg1.body, msg2.body]

      actual =
        conn
        |> json_response(200)
        |> get_in(["data", "chatHistory"])
        |> Enum.map(&Map.get(&1, "body"))

      assert expected === actual
    end
  end
end
