defmodule UserPref.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :topic, :text, null: false
      add :user_a_id, references(:users, on_delete: :nothing), null: false
      add :user_b_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:chats, [:user_a_id])
    create index(:chats, [:user_b_id])

    create unique_index(
             :chats,
             ["LEAST(user_a_id, user_b_id)", "GREATEST(user_a_id, user_b_id)"],
             name: :chats_user_pair_unique
           )
  end
end
