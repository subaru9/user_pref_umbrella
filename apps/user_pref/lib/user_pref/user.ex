defmodule UserPref.User do
  @moduledoc """
  Incapsulates composable queries
  """

  use Ecto.Schema

  alias UserPref.{Pref, Avatar}

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      update_change: 3,
      unique_constraint: 2,
      cast_assoc: 3
    ]

  import Ecto.Query,
    only: [
      where: 3,
      exclude: 2,
      order_by: 3,
      limit: 2,
      from: 2,
      join: 5
    ]

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          email: String.t() | nil,
          id: integer() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          pref: Pref.t() | Ecto.Association.NotLoaded.t(),
          avatars: Avatar.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @type params_t :: %{
          optional(:email) => String.t(),
          optional(:first_name) => String.t(),
          optional(:last_name) => String.t(),
          optional(:id) => integer(),
          optional(:pref) => Pref.params_t(),
          optional(:avatars) => [Avatar.params_t()]
        }
  @type accumulator_query_t :: Ecto.Query.t()
  @type filter_tuple_t :: {atom(), any()}
  @type filter_params :: Keyword.t() | map()

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    has_one :pref, Pref
    has_many :avatars, Avatar

    timestamps type: :utc_datetime_usec
  end

  @available_fields ~w(id first_name last_name email)a
  @required_fields ~w(email first_name last_name)a

  @spec changeset(t(), params_t()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @available_fields)
    |> validate_required(@required_fields)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> cast_assoc(:pref, with: &Pref.changeset/2)
    |> cast_assoc(:avatars, with: &Avatar.changeset/2)
  end

  @spec before_query(integer() | String.t(), accumulator_query_t()) :: accumulator_query_t()
  def before_query(id, query),
    do: where(query, [user: u], u.id < ^id)

  @spec after_query(integer() | String.t(), accumulator_query_t()) :: accumulator_query_t()
  def after_query(id, query),
    do: where(query, [user: u], u.id > ^id)

  @spec first_query(integer() | String.t(), accumulator_query_t()) :: accumulator_query_t()
  def first_query(value, query) do
    query
    |> exclude(:order_by)
    |> order_by([user: u], u.id)
    |> limit(^value)
  end

  @spec from(__MODULE__ | accumulator_query_t()) :: accumulator_query_t()
  def from(query \\ __MODULE__), do: from(query, as: :user)

  @spec join_pref :: accumulator_query_t()
  def join_pref do
    join(from(), :inner, [user: u], p in assoc(u, :pref), as: :pref)
  end
end
