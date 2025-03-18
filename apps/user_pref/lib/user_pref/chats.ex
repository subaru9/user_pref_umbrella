defmodule UserPref.Chats do
  @moduledoc """
  Access layer to chat schemas
  """
  alias EctoShorts.Actions
  alias UserPref.Chats.{Chat, Message}

  @type dataloader :: Dataloader.Ecto.t()
  @type create_chat_params :: %{
          optional(:topic) => String.t(),
          required(:user_a_id) => non_neg_integer(),
          required(:user_b_id) => non_neg_integer()
        }
  @type create_message_params :: %{
          required(:user_id) => non_neg_integer(),
          required(:body) => String.t(),
          required(:chat_id) => non_neg_integer()
        }
  @type history_params :: %{
          optional(:cursor) => non_neg_integer(),
          required(:last) => non_neg_integer(),
          required(:chat_id) => non_neg_integer()
        }

  @spec find_or_create_chat(
          params :: create_chat_params(),
          opts :: Actions.opts()
        ) :: ErrorMessage.t_res(Chat.t(), Ecto.Changeset.t())
  def find_or_create_chat(params, opts \\ []) do
    with {:error, changeset = %Ecto.Changeset{}} <-
           Actions.find_or_create(Chat, params, opts) do
      {:error, ErrorMessage.unprocessable_entity("invalid request data", changeset)}
    end
  end

  @spec create_message(
          params :: create_message_params(),
          opts :: Actions.opts()
        ) :: ErrorMessage.t_res(Message.t(), Ecto.Changeset.t())
  def create_message(params, opts \\ []) do
    with {:error, changeset = %Ecto.Changeset{}} <-
           Actions.create(Message, params, opts) do
      {:error, ErrorMessage.unprocessable_entity("invalid request data", changeset)}
    end
  end

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
  the latest message ommited when using :before filter.
  Cursor is grabbed from the first message of the batch
  """
  def history(%{last: limit, chat_id: chat_id}, opts) do
    Actions.all(Message, %{last: limit, chat_id: chat_id}, opts)
  end

  def history(_, _), do: []

  @spec datasource :: dataloader
  def datasource, do: Dataloader.Ecto.new(UserPref.Repo, query: &query/2)
  defp query(queryable, _), do: queryable
end
