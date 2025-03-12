defmodule UserPref.Support.Fixtures do
  @moduledoc """
  Fixtures for testing
  """
  alias UserPref.{User, Chats.Chat, Chats.Message}

  @spec user_fixture(User.params_t()) :: User.t()
  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    first_name = attrs[:first_name] || "user-#{unique_id}"
    last_name = attrs[:last_name] || "test"
    email = attrs[:email] || "#{first_name}.#{last_name}@example.com"

    default_attrs = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      pref: %{
        likes_emails: false,
        likes_phone_calls: false,
        likes_faxes: false
      }
    }

    merged_attrs = Map.merge(default_attrs, attrs)

    {:ok, user} = UserPref.create_user(merged_attrs)

    user
  end

  @spec chat_fixture(map()) :: Chat.t()
  def chat_fixture(attrs \\ %{}) do
    user_a = attrs[:user_a] || user_fixture()
    user_b = attrs[:user_b] || user_fixture()

    default_attrs = %{
      topic: attrs[:topic] || "General Discussion #{user_a.id}, #{user_b.id}",
      user_a_id: user_a.id,
      user_b_id: user_b.id
    }

    merged_attrs = Map.merge(default_attrs, attrs)

    {:ok, chat} = UserPref.Chats.find_or_create_chat(merged_attrs)

    chat
  end

  @spec message_fixture(map()) :: Message.t()
  def message_fixture(attrs \\ %{}) do
    chat = attrs[:chat] || chat_fixture()
    sender = attrs[:user] || chat.user_a

    default_attrs = %{
      body: attrs[:body] || "Hello, this is a test message from #{sender.id}!",
      chat_id: chat.id,
      user_id: sender.id
    }

    merged_attrs = Map.merge(default_attrs, attrs)

    {:ok, message} = UserPref.Chats.create_message(merged_attrs)

    message
  end
end
