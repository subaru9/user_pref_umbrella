defmodule UserPref.ChatsTest do
  use UserPref.DataCase

  describe "&history/2" do
    test "reverse cursor pagination" do
      user_a = Fixtures.user_fixture()
      user_b = Fixtures.user_fixture()

      chat = Fixtures.chat_fixture(%{user_a: user_a, user_b: user_b})

      message1_user_a = Fixtures.message_fixture(%{user: user_a, chat: chat})
      message2_user_a = Fixtures.message_fixture(%{user: user_a, chat: chat})
      message3_user_b = Fixtures.message_fixture(%{user: user_b, chat: chat})
      message4_user_a = Fixtures.message_fixture(%{user: user_a, chat: chat})

      actual = UserPref.Chats.history(%{last: 2, chat_id: chat.id})
      expected = [message3_user_b, message4_user_a]

      assert expected === actual

      cursor = actual |> List.first() |> Map.fetch!(:id)

      expected1 = [message1_user_a, message2_user_a]
      actual1 = UserPref.Chats.history(%{cursor: cursor, last: 2, chat_id: chat.id})

      assert expected1 === actual1
    end
  end
end
