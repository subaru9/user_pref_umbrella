defmodule SharedUtils.ErrorTest do
  @moduledoc false

  use ExUnit.Case

  alias SharedUtils.Error

  describe "&internal_server_error/2" do
    test "given valid args, returns valid struct" do
      %ErrorMessage{
        message: "something wrong",
        details: [request_id: 456],
        code: :internal_server_error
      } = Error.internal_server_error("something wrong", request_id: 456)
    end

    @compile {:no_warn_undefined, {Error, :undefined, 2}}
    test "raises if urror function is not defined" do
      assert_raise(UndefinedFunctionError, fn ->
        Error.undefined("undefined function error", %{})
      end)
    end
  end
end
