defmodule UserPref.Repo do
  use Ecto.Repo,
    otp_app: :user_pref,
    adapter: Ecto.Adapters.Postgres
end
