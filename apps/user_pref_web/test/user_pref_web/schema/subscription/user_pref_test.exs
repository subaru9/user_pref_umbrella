defmodule UserPrefWeb.Schema.Subscription.UserPrefTest do
  use UserPrefWeb.SubscriptionCase

  @pref_updated_sub_doc """
    subscription prefUpdated($userId: ID!) {
      prefUpdated(userId: $userId) {
        likesEmails
        likesPhoneCalls
        likesFaxes
      }
    }
  """

  @update_pref_doc """
    mutation updatePref($input: UpdatePrefInput) {
      updatePref(input: $input) {
        userId
        likesEmails
        likesPhoneCalls
        likesFaxes
      }
    }
  """

  describe "@prefUpdated" do
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

      user = user_fixture(params)

      # Generate JWT token for authentication
      secret = Auth.Config.fetch_secret()
      # Set token to expire in 1 hour
      exp = :os.system_time(:second) + 3600
      payload = %{"sub" => user.id, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)

      conn = Phoenix.ConnTest.build_conn()
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token}")

      {:ok, user: user, conn: conn}
    end

    test "pref updated subscription", %{socket: socket, user: user, conn: conn} do
      ref = push_doc(socket, @pref_updated_sub_doc, variables: %{"userId" => user.id})
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      update_pref_input = %{
        userId: user.id,
        likesEmails: false,
        likesPhoneCalls: true,
        likesFaxes: false
      }

      conn =
        post(conn, "/api",
          query: @update_pref_doc,
          variables: %{"input" => update_pref_input}
        )

      %{
        "data" => %{
          "updatePref" => %{
            "likesEmails" => false,
            "likesFaxes" => false,
            "likesPhoneCalls" => true,
            "userId" => id
          }
        }
      } = json_response(conn, 200)

      assert id === Integer.to_string(user.id)

      expected_push = %{
        result: %{
          data: %{
            "prefUpdated" => %{
              "likesEmails" => false,
              "likesFaxes" => false,
              "likesPhoneCalls" => true
            }
          }
        },
        subscriptionId: subscription_id
      }

      assert_push "subscription:data", push
      assert push === expected_push
    end
  end

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

  @user_created_sub_doc """
    subscription userCreated {
      userCreated {
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

  describe "@userCreated" do
    setup do
      secret = Auth.Config.fetch_secret()
      # Set token to expire in 1 hour
      exp = :os.system_time(:second) + 3600
      # Example user_id of 1
      payload = %{"sub" => 1, "exp" => exp}
      auth_token = Auth.Token.create(payload, secret)

      conn = Phoenix.ConnTest.build_conn()
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token}")

      {:ok, conn: conn}
    end

    test "user created subscription", %{socket: socket, conn: conn} do
      ref = push_doc(socket, @user_created_sub_doc, [])
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      first_name = "John"
      GiphyApi.Support.TestHelpers.mock_giphy_responses(first_name)

      user_with_pref_input = %{
        first_name: first_name,
        last_name: "Doe",
        email: "john_doe@gmail.com",
        pref: %{
          likes_emails: true,
          likes_phone_calls: false,
          likes_faxes: true
        }
      }

      conn =
        post(conn, "/api",
          query: @create_user_doc,
          variables: %{"input" => user_with_pref_input}
        )

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

      expected_push = %{
        result: %{
          data: %{
            "userCreated" => %{
              "id" => id,
              "email" => email,
              "firstName" => first_name,
              "lastName" => last_name,
              "pref" => %{
                "likesEmails" => true,
                "likesFaxes" => true,
                "likesPhoneCalls" => false
              }
            }
          }
        },
        subscriptionId: subscription_id
      }

      assert_push "subscription:data", push
      assert push === expected_push
    end
  end
end
