defmodule UserPrefWeb.Resolvers.UserAvatarsWorker do
  use Oban.Worker,
    queue: :user_avatars,
    max_attempts: 3,
    unique: [keys: [:user_id, :first_name], period: :infinity]

  @type user_id :: integer()
  @type first_name :: String.t()
  @type oban_job :: %Oban.Job{args: map()}
  @type oban_changeset :: Ecto.Changeset.t()
  @type oban_result :: {:ok, Oban.Job.t()} | {:error, ErrorMessage.t()}
  @type perform_result :: {:ok, map()}| {:ok, [any(), ...], [any(), ...]} | {:error, ErrorMessage.t()}

  alias UserPref.Avatar

  @spec perform(oban_job) :: perform_result
  def perform(%Oban.Job{args: %{"user_id" => user_id, "first_name" => first_name}}) do
    with {:ok, gifs} <- GiphyApi.search(first_name) do
      user_gifs = Enum.map(gifs, &Map.put(&1, :user_id, user_id))

      UserPref.create_many(Avatar, user_gifs)
    end
  end

  @spec enqueue(user_id, first_name) :: oban_result
  def enqueue(user_id, first_name) do
    %{"user_id" => user_id, "first_name" => first_name}
    |> new()
    |> then(&Oban.insert(UserPref.Oban, &1))
    |> case do
      {:ok, _res} = result ->
        result

      {:error, job_changeset} ->
        {:error, ErrorMessage.unprocessable_entity("Failed to enqueue the job", job_changeset)}
    end
  end
end
