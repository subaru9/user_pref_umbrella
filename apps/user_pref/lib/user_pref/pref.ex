defmodule UserPref.Pref do
  @moduledoc """
  Encapsulates the schema, changeset for data validation,
  and CRUD operations
  """

  use Ecto.Schema

  alias UserPref.User

  import Ecto.Changeset
  import Ecto.Query

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          likes_emails: boolean(),
          likes_phone_calls: boolean(),
          likes_faxes: boolean(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          user_id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @type params_t :: %{
          optional(:likes_emails) => boolean(),
          optional(:likes_phone_calls) => boolean(),
          optional(:likes_faxes) => boolean(),
          optional(:user_id) => integer()
        }

  @type accumulator_query_t :: Ecto.Query.t()

  schema "prefs" do
    field :likes_emails, :boolean, default: false
    field :likes_phone_calls, :boolean, default: false
    field :likes_faxes, :boolean, default: false

    belongs_to :user, User

    timestamps type: :utc_datetime_usec
  end

  @available_fields ~w(likes_emails likes_phone_calls likes_faxes user_id)a

  @spec changeset(t(), params_t()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @available_fields)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id)
  end

  @spec likes_emails_query(boolean(), accumulator_query_t()) :: accumulator_query_t()
  def likes_emails_query(value, query),
    do: where(query, [pref: p], p.likes_emails == ^value)

  @spec likes_faxes_query(boolean(), accumulator_query_t()) :: accumulator_query_t()
  def likes_faxes_query(value, query),
    do: where(query, [pref: p], p.likes_faxes == ^value)

  @spec likes_phone_calls_query(boolean(), accumulator_query_t()) :: accumulator_query_t()
  def likes_phone_calls_query(value, query),
    do: where(query, [pref: p], p.likes_phone_calls == ^value)
end
