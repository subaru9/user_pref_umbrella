defmodule UserPrefWeb.Resolvers.Chat do
  @moduledoc """
  Resolvers for Chat GraphQL operations
  """
  alias UserPref.Chats
  alias UserPref.Chats.{Chat, Message}

  @type resolution :: Absinthe.Resolution.t()
  @type chat :: Chat.t()
  @type message :: Message.t()
  @type create_chat_params :: %{
          input: %{
            optional(:topic) => String.t(),
            required(:user_b_id) => non_neg_integer()
          }
        }
  @type create_message_params :: %{
          input: %{
            required(:body) => String.t(),
            required(:chat_id) => non_neg_integer()
          }
        }
  @spec create_chat(
          input :: create_chat_params(),
          res :: resolution()
        ) :: ErrorMessage.t_res(Chat.t(), Ecto.Changeset.t() | create_chat_params())
  def create_chat(%{input: params}, %{context: %{current_user_id: current_user_id}}) do
    params
    |> Map.put(:user_a_id, current_user_id)
    |> Chats.find_or_create_chat()
  end

  @spec create_message(
          input :: create_message_params(),
          res :: resolution()
        ) :: ErrorMessage.t_res(Message.t(), Ecto.Changeset.t() | create_message_params())
  def create_message(%{input: params}, %{context: %{current_user_id: current_user_id}}) do
    params
    |> Map.put(:user_id, current_user_id)
    |> Chats.create_message()
  end
end
