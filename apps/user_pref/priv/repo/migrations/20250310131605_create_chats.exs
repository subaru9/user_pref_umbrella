defmodule UserPref.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :topic, :text, null: false
      add :member_a_id, references(:users, on_delete: :nothing), null: false
      add :member_b_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:chats, [:member_a_id])
    create index(:chats, [:member_b_id])

    create unique_index(:chats, [:topic], name: :chats_topic_unique)

    create unique_index(
             :chats,
             ["LEAST(member_a_id, member_b_id)", "GREATEST(member_a_id, member_b_id)"],
             name: :chats_member_pair_unique
           )
  end
end
