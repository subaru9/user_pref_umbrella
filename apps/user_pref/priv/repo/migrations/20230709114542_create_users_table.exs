defmodule UserPref.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table :users do
      add :first_name, :text, null: false
      add :last_name, :text, null: false
      add :email, :text, null: false

      timestamps type: :utc_datetime_usec
    end

    create unique_index :users, [:email]
  end
end
