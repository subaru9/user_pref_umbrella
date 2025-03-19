defmodule UserPrefWeb.Schema.Query.Chat do
  @moduledoc """
  Queries for chats
  """
  use Absinthe.Schema.Notation
  alias UserPrefWeb.Resolvers.Chat

  object :chat_queries do
    @desc "Get message history"
    field :chat_history, list_of(:message) do
      arg :input, non_null(:chat_history_input)

      resolve &Chat.history/2
    end
  end
end
