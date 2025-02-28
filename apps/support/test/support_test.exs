defmodule SupportTest do
  use ExUnit.Case
  doctest Support

  test "greets the world" do
    assert Support.hello() == :world
  end
end
