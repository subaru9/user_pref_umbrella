defmodule BgJobs.Repo do
  use Ecto.Repo, 
    otp_app: :bg_jobs,
    adapter: Ecto.Adapters.Postgres
end
