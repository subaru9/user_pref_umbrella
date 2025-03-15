defmodule UserPrefWeb.Schema.Mutation.Chat do
  @moduledoc """
  Mutations for chats
  """
  use Absinthe.Schema.Notation

  alias UserPrefWeb.Resolvers.Chat

  object :chat_mutations do
    @desc "Create chat"
    field :create_chat, :chat do
      arg :input, :create_chat_input
      resolve &Chat.create_chat/2
    end

    @desc "Create message"
    field :create_message, :message do
      arg :input, :create_message_input
      resolve &Chat.create_message/2
    end
  end
end
