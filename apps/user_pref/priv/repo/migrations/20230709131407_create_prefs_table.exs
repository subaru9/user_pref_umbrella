defmodule UserPref.Repo.Migrations.CreatePrefsTable do
  use Ecto.Migration

  def change do
    create table :prefs do
      add :likes_emails, :boolean, default: false
      add :likes_phone_calls, :boolean, default: false
      add :likes_faxes, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps type: :utc_datetime_usec
    end

    create unique_index :prefs, [:user_id]
  end
end
