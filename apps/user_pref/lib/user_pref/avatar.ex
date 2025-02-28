defmodule UserPref.Avatar do
  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, assoc_constraint: 3, validate_required: 2]

  alias UserPref.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          remote_id: String.t() | nil,
          url: String.t() | nil,
          username: String.t() | nil,
          title: String.t() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          user_id: non_neg_integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
  @type params_t :: %{
          optional(:remote_id) => String.t(),
          optional(:url) => String.t(),
          optional(:username) => String.t(),
          optional(:title) => String.t(),
          optional(:user_id) => integer()
        }
  @available_keys ~w(id url username title user_id remote_id)a
  @required_keys ~w(url)a

  schema "avatars" do
    field :remote_id, :string
    field :url, :string
    field :username, :string
    field :title, :string
    belongs_to :user, User
    timestamps type: :utc_datetime_usec
  end

  def changeset(%__MODULE__{} = avatar, attrs) do
    avatar
    |> cast(attrs, @available_keys)
    |> validate_required(@required_keys)
    |> assoc_constraint(:user, name: :avatars_user_id_fkey)
  end

  def create_changeset(params \\ %{}) do
    %__MODULE__{}
    |> changeset(params)
    |> validate_required(:user_id)
  end
end
