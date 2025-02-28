defmodule Auth.TokensTest do
  use UserPref.DataCase, async: true

  alias Auth.Tokens

  @secret "super_secret_key"

  setup do
    Tokens.Cache.clear()

    on_exit(fn -> Tokens.Cache.clear() end)

    :ok
  end

  describe "&create/3" do
    test "generates a token with a valid user ID and ttl" do
      user_id = 123
      ttl = 3600

      {token, exp_time} = Tokens.create(user_id, ttl, @secret)

      [_header, payload, _signature] = String.split(token, ".")
      decoded_payload = decode_base64_payload(payload)

      current_time = :os.system_time(:second)
      expected_exp_time = current_time + ttl
      assert exp_time === expected_exp_time
      assert decoded_payload["exp"] === exp_time
      assert decoded_payload["sub"] === user_id
    end

    test "returns a valid JWT token format" do
      user_id = 456
      ttl = 1800

      {token, _exp_time} = Tokens.create(user_id, ttl, @secret)

      assert token |> String.split(".") |> length() === 3
    end
  end

  defp decode_base64_payload(payload) do
    payload
    |> Base.url_decode64!(padding: false)
    |> Jason.decode!()
  end

  describe "&refresh/2" do
    setup do
      user_id = 123
      ttl = 3600

      {:ok, user_id: user_id, ttl: ttl, secret: @secret}
    end

    test "creates a new token if the existing one is expired", %{
      user_id: user_id,
      ttl: ttl,
      secret: secret
    } do
      exp_time = :os.system_time(:second) - 10
      expired_token = Tokens.create(user_id, -10, secret)
      Tokens.Cache.put(user_id, {expired_token, exp_time})

      refreshed = Tokens.refresh(user_id, %{ttl: ttl, secret: secret})

      assert refreshed !== nil
      assert refreshed.key === user_id
      assert refreshed.val !== expired_token
    end

    test "creates a new token if no token exists", %{user_id: user_id, ttl: ttl, secret: secret} do
      refreshed = Tokens.refresh(user_id, %{ttl: ttl, secret: secret})

      assert refreshed !== nil
      assert refreshed.key === user_id
      assert is_tuple(refreshed.val)
    end

    test "does not create a new token if the existing token is still valid", %{
      user_id: user_id,
      ttl: ttl,
      secret: secret
    } do
      valid_exp_time = :os.system_time(:second) + ttl
      valid_token = Tokens.create(user_id, ttl, secret)
      Tokens.Cache.put(user_id, {valid_token, valid_exp_time})

      refreshed = Tokens.refresh(user_id, %{ttl: ttl, secret: secret})

      assert refreshed === nil
    end
  end
end
