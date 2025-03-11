defmodule UserPref.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :chat_id, references(:chats, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:messages, [:user_id])
    create index(:messages, [:chat_id])
  end
end
