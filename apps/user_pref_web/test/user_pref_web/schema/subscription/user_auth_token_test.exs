defmodule UserPrefWeb.Schema.Subscription.UserAuthTokenTest do
  use UserPrefWeb.SubscriptionCase

  @user_auth_token_sub_doc """
    subscription newAuthToken($userId: ID!) {
      newAuthToken(userId: $userId)
    }
  """

  describe "@userAuthToken" do
    setup do
      params = %{
        id: 1,
        first_name: "Alice",
        last_name: "Doe",
        email: "alice@example.com"
      }

      [user: user_fixture(params)]
    end

    test "user auth token subscription", %{socket: socket, user: user} do
      #
      # 1. Set up a subscription to the user_auth_token topic for the user
      #
      ref = push_doc(socket, @user_auth_token_sub_doc, variables: %{"userId" => user.id})
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      #
      # 2. Trigger the subscription by creating an auth token for the user
      #
      config = Auth.Config.tokens()
      token_ttl = config[:ttl]
      token_secret = config[:secret]

      {token, _exp_time} = Auth.Tokens.create(user.id, token_ttl, token_secret)

      UserPrefWeb.Broadcast.publish_new_auth_token(user.id, token)

      #
      # 3. Assert that the expected subscription data was pushed to us
      #
      expected_push = %{
        result: %{
          data: %{
            "newAuthToken" => token
          }
        },
        subscriptionId: subscription_id
      }

      assert_push "subscription:data", push
      assert push === expected_push
    end
  end
end
