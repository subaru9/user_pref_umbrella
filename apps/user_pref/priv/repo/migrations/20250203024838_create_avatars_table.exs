defmodule UserPref.Repo.Migrations.CreateAvatarsTable do
  use Ecto.Migration

  def change do
    create table :avatars do
      add :remote_id, :string
      add :url, :string, null: false
      add :username, :string
      add :title, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps type: :utc_datetime_usec
    end

    create index :avatars, [:user_id]
  end
end
