defmodule UserPref.Chats do
  @moduledoc """
  Access layer to chat schemas
  """
  alias EctoShorts.Actions
  alias UserPref.Chats.{Chat, Message}

  @spec find_or_create_chat(
          params :: Chat.create_params(),
          opts :: Actions.opts()
        ) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_chat(params, opts \\ []) do
    Actions.find_or_create(Chat, params, opts)
  end

  @spec create_message(
          params :: Message.create_params(),
          opts :: Actions.opts()
        ) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def create_message(params, opts \\ []) do
    Actions.create(Message, params, opts)
  end

  @type history_params :: %{
          optional(:cursor) => non_neg_integer(),
          required(:last) => non_neg_integer(),
          required(:chat_id) => non_neg_integer()
        }
  @spec history(
          params :: history_params(),
          opts :: Actions.opts()
        ) :: Actions.schemas()
  def history(params, opts \\ [])

  def history(%{cursor: cursor, last: limit, chat_id: chat_id}, opts) do
    Actions.all(Message, %{before: cursor, last: limit, chat_id: chat_id}, opts)
  end

  @doc """
  Used to fetch initial message batch which icludes 
  the latest message ommited when using :before filter
  """
  def history(%{last: limit, chat_id: chat_id}, opts) do
    Actions.all(Message, %{last: limit, chat_id: chat_id}, opts)
  end

  def history(_, _), do: []
end
