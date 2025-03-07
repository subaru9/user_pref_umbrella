defmodule Auth.Tokens.ProducerTest do
  use ExUnit.Case

  alias UserPref.Support.Fixtures
  alias Auth.Tokens.Producer

  describe "state transitions" do
    test "start with correct state" do
      {:ok, pid} = GenStage.start_link(Producer, :ok)

      assert :sys.get_state(pid).state === %{cursor: 0}
    end

    test "updates the cursor after processing demand" do
      users = [Fixtures.user_fixture(), Fixtures.user_fixture(), Fixtures.user_fixture()]
      id = users |> Enum.map(&(&1.id)) |> Enum.max()

      {:ok, pid} = GenStage.start_link(Producer, :ok)
      Process.send(pid, :trigger, [])

      assert :sys.get_state(pid).state === %{cursor: id}
    end
  end
end
