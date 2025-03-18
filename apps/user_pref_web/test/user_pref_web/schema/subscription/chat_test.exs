defmodule UserPrefWeb.Schema.Subscription.ChatTest do
  use UserPrefWeb.SubscriptionCase

  alias Auth.Support.AuthHelper

  @message_created_sub_doc """
    subscription messageCreated($chatId: ID!) {
      messageCreated(chatId: $chatId) {
        id
        body
        chat { id }
        user { id }
        inserted_at
      }
    }
  """

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
      user_a = user_fixture(%{id: 1})
      user_b = user_fixture(%{id: 2})
      chat = chat_fixture(%{user_a: user_a, user_b: user_b})

      {:ok, conn: conn, user_a: user_a, user_b: user_b, chat: chat}
    end

    test "pushes expected data to the subscribers", %{
      socket: socket,
      conn: conn,
      user_a: user_a,
      user_b: user_b,
      chat: chat
    } do
      #
      # 1. Set up a subscription to the chat topic configured for the subscription
      #
      ref = push_doc(socket, @message_created_sub_doc, variables: %{"chatId" => chat.id})
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      #
      # 2. Trigger the subscription by creating a message by user_a
      #
      expected_user_a_message_body = "user_a blah"
      expected_chat_id = chat.id

      input_var = %{
        body: expected_user_a_message_body,
        chat_id: expected_chat_id
      }

      user_a_token = AuthHelper.generate_token(user_a.id)

      conn
      |> put_req_header("authorization", "Bearer #{user_a_token}")
      |> post("/api", query: @create_message_doc, variables: %{"input" => input_var})

      #
      # 3. Assert that the expected subscription data was pushed to socket
      #
      assert_push "subscription:data", actual_push

      %{
        result: %{
          data: %{
            "messageCreated" => %{
              "body" => actual_user_a_message_body,
              "chat" => %{"id" => actual_chat_id},
              "id" => actual_message_id,
              "user" => %{"id" => actual_user_a_id}
            }
          }
        },
        subscriptionId: actual_subscription_id
      } = actual_push

      assert actual_subscription_id === subscription_id  
      assert actual_message_id
      assert user_a.id === String.to_integer(actual_user_a_id)
      assert expected_user_a_message_body === actual_user_a_message_body
      assert expected_chat_id === String.to_integer(actual_chat_id)
      #
      # 4. Trigger the subscription by creating a message by user_b
      #
      expected_user_b_message_body = "user_b blah"
      expected_chat_id = chat.id

      input_var = %{
        body: expected_user_b_message_body,
        chat_id: expected_chat_id
      }

      user_b_token = AuthHelper.generate_token(user_b.id)

      conn
      |> put_req_header("authorization", "Bearer #{user_b_token}")
      |> post("/api", query: @create_message_doc, variables: %{"input" => input_var})

      #
      # 5. Assert that the expected subscription data was pushed to socket
      #
      assert_push "subscription:data", actual_push

      %{
        result: %{
          data: %{
            "messageCreated" => %{
              "body" => actual_user_b_message_body,
              "chat" => %{"id" => actual_chat_id},
              "id" => actual_message_id,
              "user" => %{"id" => actual_user_b_id}
            }
          }
        },
        subscriptionId: actual_subscription_id
      } = actual_push

      assert actual_subscription_id === subscription_id  
      assert actual_message_id
      assert user_b.id === String.to_integer(actual_user_b_id)
      assert expected_user_b_message_body === actual_user_b_message_body
      assert expected_chat_id === String.to_integer(actual_chat_id)
    end
  end
end
