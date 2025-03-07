defmodule Auth.Tokens.ConsumerTest do
  use ExUnit.Case

  describe "cache storage" do
    test "refreshed token stored in the cache" do
      Auth.Tokens.Cache.clear()
      user_id = 1234
      {:ok, _pid} = Auth.Tokens.Consumer.start_link(%{id: user_id})
      :timer.sleep(100)
      {token, exp_time} = Auth.Tokens.get(user_id)
      assert not is_nil(token)
      assert not is_nil(exp_time)
    end
  end
end
