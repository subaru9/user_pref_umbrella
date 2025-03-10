defmodule UserPref.Chat do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 3,
      foreign_key_constraint: 2
    ]

  alias UserPref.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          topic: String.t(),
          user_a: User.t() | Ecto.Association.NotLoaded.t(),
          user_a_id: non_neg_integer() | nil,
          user_b_id: non_neg_integer() | nil,
          user_b: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @type params :: %{
          required(:topic) => String.t(),
          required(:user_a_id) => non_neg_integer(),
          required(:user_b_id) => non_neg_integer()
        }

  @available_fields [:topic, :user_a_id, :user_b_id]
  @required_fields [:topic, :user_a_id, :user_b_id]

  schema "chats" do
    field :topic, :string

    belongs_to :user_a, User
    belongs_to :user_b, User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:topid, name: :chats_topic_unique)
    |> unique_constraint(:user_a_id, name: :chats_user_pair_unique)
    |> foreign_key_constraint(:user_a_id)
    |> foreign_key_constraint(:user_b_id)
  end
end
