defmodule AuthTest do
  use ExUnit.Case

  describe "&authenticate/1" do
    setup do
      secret = Auth.Config.fetch_secret()
      exp = :os.system_time(:second) + 3600
      user_id = 1
      payload = %{"sub" => user_id, "exp" => exp}
      [payload: payload, user_id: user_id, secret: secret]
    end

    test "with valid token returns expetcted results", %{
      payload: payload,
      secret: secret,
      user_id: user_id
    } do
      auth_token = Auth.Token.create(payload, secret)
      expected = {:ok, user_id}

      assert expected === Auth.authenticate(auth_token)
    end

    test "with invalid token - errores", %{payload: payload} do
      wrong_auth_token = Auth.Token.create(payload, "wrong_secret")

      error = %ErrorMessage{
        code: :unauthorized,
        message: "[Auth.Token.JWT] Invalid token or signature verification failed",
        details: %{}
      }

      expected = {:error, error}

      assert expected === Auth.authenticate(wrong_auth_token)
    end
  end
end
