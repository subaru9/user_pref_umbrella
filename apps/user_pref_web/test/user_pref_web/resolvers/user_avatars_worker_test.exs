defmodule UserPref.Workers.UserAvatarsWorkerTest do
  use UserPref.DataCase

  alias UserPrefWeb.Resolvers.UserAvatarsWorker

  @attempted_by ["user_pref@localhost"]

  describe "&enqueue/2" do
    setup do
      first_name = "John"
      GiphyApi.Support.TestHelpers.mock_giphy_responses(first_name)

      %User{id: user_id, first_name: first_name} =
        Fixtures.user_fixture(%{first_name: first_name})

      {:ok, user_id: user_id, first_name: first_name}
    end

    test "successfully enqueues a job", %{user_id: user_id, first_name: first_name} do
      assert {:ok,
              %Oban.Job{
                queue: "user_avatars",
                state: "completed",
                attempt: 1,
                attempted_by: @attempted_by
              }} =
               UserAvatarsWorker.enqueue(user_id, first_name)
    end

    test "fails when given invalid arguments", %{first_name: first_name} do
      assert {:ok,
              %Oban.Job{
                errors: [_ | _],
                queue: "user_avatars",
                state: "retryable",
                attempt: 1,
                attempted_by: @attempted_by
              }} =
               UserAvatarsWorker.enqueue(nil, first_name)
    end

    test "enqueue duplicate jobs with conflict", %{user_id: user_id, first_name: first_name} do
      Oban.Testing.with_testing_mode(:manual, fn ->
        {:ok, _job1} = UserAvatarsWorker.enqueue(user_id, first_name)

        assert {:ok,
                %Oban.Job{
                  state: "available",
                  conflict?: true
                }} =
                 UserAvatarsWorker.enqueue(user_id, first_name)
      end)
    end
  end
end
