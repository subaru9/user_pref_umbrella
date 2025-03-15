defmodule Auth.Support.AuthHelper do
  def generate_token(user_id, ttl \\ 3600) do
    secret = Auth.Config.fetch_secret()
    exp = :os.system_time(:second) + ttl
    payload = %{"sub" => user_id, "exp" => exp}

    Auth.Token.create(payload, secret)
  end
end
