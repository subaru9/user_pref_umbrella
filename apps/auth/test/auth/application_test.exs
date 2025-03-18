defmodule Auth.ApplicationTest do
  use ExUnit.Case, async: true

  test "starts Auth application supervision tree" do
    assert {:ok, pid} = Auth.Application.start(:normal, [])
    assert Process.alive?(pid)
  end
end
