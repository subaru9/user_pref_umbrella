defmodule Auth.Tokens.ProducerTest do
  use UserPref.DataCase

  alias Auth.Tokens.Producer

  describe "state transitions" do
    test "start with correct state" do
      {:ok, pid} = GenStage.start_link(Producer, :ok)

      assert :sys.get_state(pid).state === %{cursor: 0}
    end

    test "updates the cursor after processing demand" do
      users = [user_fixture(), user_fixture(), user_fixture()]
      id = users |> Enum.map(&(&1.id)) |> Enum.max()

      {:ok, pid} = GenStage.start_link(Producer, :ok)
      Process.send(pid, :trigger, [])

      assert :sys.get_state(pid).state === %{cursor: id}
    end
  end
end
