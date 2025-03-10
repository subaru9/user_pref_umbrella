defmodule UserPref.Chat do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      unique_constraint: 3
    ]

  @available_fields [:topic, :member_a_id, :member_b_id]
  @required_fields [:topic, :member_a_id, :member_b_id]

  schema "chats" do
    field :topic, :string
    field :member_a_id, :id
    field :member_b_id, :id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:topid, name: :chats_topic_unique)
    |> unique_constraint(:member_a_id, name: :chats_member_pair_unique)
  end
end
