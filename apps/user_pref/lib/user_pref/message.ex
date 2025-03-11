defmodule UserPref.Message do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      foreign_key_constraint: 2
    ]

  alias UserPref.{Chat, User}

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: non_neg_integer() | nil,
          body: String.t() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          user_id: non_neg_integer() | nil,
          chat: Chat.t() | Ecto.Association.NotLoaded.t(),
          chat_id: non_neg_integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @type params :: %{
          required(:body) => String.t(),
          required(:user_id) => non_neg_integer(),
          required(:chat_id) => non_neg_integer()
        }

  @available_fields [:body, :user_id, :chat_id]
  @required_fields [:body, :user_id, :chat_id]

  schema "messages" do
    field :body, :string

    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:chat_id)
  end
end
