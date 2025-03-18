defmodule UserPrefWeb.Schema.Subscription.Chat do
  @moduledoc """
  Subscriptions for chats
  """
  use Absinthe.Schema.Notation

  object :chat_subscriptions do
    @desc "Chat message will be broadcasted on message creation"
    field :message_created, :message do
      arg :chat_id, non_null(:id)

      # This is also where we can perform other checks like 
      # authorization to accept/reject the subscription. 
      # The function passed to config receives the arguments passed 
      # to the field and the Absinthe.Resolution struct that contains 
      # information like context.
      config fn %{chat_id: chat_id}, _resolution ->
        {:ok, topic: "chat:#{chat_id}"}
      end

      # trigger publishing to a topic on mutation (:create_message) 
      trigger :create_message,
        # topic name formed by anonymous function with mutation
        # result as argument
        topic: fn message ->
          "chat:#{message.chat_id}"
        end
    end
  end
end
