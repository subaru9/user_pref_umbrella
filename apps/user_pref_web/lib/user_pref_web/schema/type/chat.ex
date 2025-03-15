defmodule UserPrefWeb.Schema.Type.Chat do
  @moduledoc """
  Chat realated types, like messages
  """

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :chat do
    field :id, :id
    field :topic, :string
    field :user_a, :user, resolve: dataloader(UserPref)
    field :user_b, :user, resolve: dataloader(UserPref)
    field :messages, list_of(:message), resolve: dataloader(Chats)
    field :inserted_at, :utc_datetime_usec
  end

  object :message do
    field :id, :id
    field :body, :string
    field :chat, :chat, resolve: dataloader(Chats)
    field :user, :user, resolve: dataloader(UserPref)
    field :inserted_at, :utc_datetime_usec
  end

  input_object :create_message_input do
    field :body, non_null(:string)
    field :user_id, non_null(:id)
    field :chat_id, non_null(:id)
  end

  input_object :create_chat_input do
    field :topic, :string
    field :user_b_id, non_null(:id)
  end
end
