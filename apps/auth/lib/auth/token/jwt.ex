defmodule Auth.Token.JWT do
  @moduledoc "Handles JWT creation and validation for authentication."

  alias SharedUtils.Error

  def create(payload, secret) do
    header = %{"alg" => "HS256", "typ" => "JWT"}
    encoded_header = encode(header)
    encoded_payload = encode(payload)
    signature = create_signature(encoded_header, encoded_payload, secret)
    "#{encoded_header}.#{encoded_payload}.#{signature}"
  end

  def validate(token, secret) do
    with [header_b64, payload_b64, signature_b64] <- String.split(token, "."),
         recreated_signature <- create_signature(header_b64, payload_b64, secret),
         true <- recreated_signature === signature_b64,
         {:ok, payload_json} <- Base.url_decode64(payload_b64, padding: false),
         {:ok, payload} <- Jason.decode(payload_json),
         {:ok, valid_payload} <- verify_claims(payload) do
      {:ok, valid_payload}
    else
      %ErrorMessage{} = error ->
        error

      _ ->
        Error.unauthorized("[Auth.Token.JWT] Invalid token or signature verification failed")
    end
  end

  defp encode(data) do
    data
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end

  defp sign(data, secret) do
    :hmac
    |> :crypto.mac(:sha256, secret, data)
    |> Base.url_encode64(padding: false)
  end

  defp create_signature(header_b64, payload_b64, secret) do
    data_to_sign = "#{header_b64}.#{payload_b64}"
    sign(data_to_sign, secret)
  end

  defp verify_claims(payload) do
    with {:ok, payload} <- verify_exp(payload),
         {:ok, payload} <- verify_sub(payload) do
      {:ok, payload}
    else
      error -> error
    end
  end

  defp verify_exp(%{"exp" => exp} = payload) when is_integer(exp) do
    if exp >= :os.system_time(:second) do
      {:ok, payload}
    else
      Error.unauthorized("[Auth.Token.JWT] Token expired")
    end
  end

  defp verify_exp(_), do: Error.bad_request("[Auth.Token.JWT] No valid expiration claim")

  defp verify_sub(%{"sub" => sub} = payload) when is_integer(sub) and sub > 0 do
    {:ok, payload}
  end

  defp verify_sub(_), do: Error.bad_request("[Auth.Token.JWT] No valid subject claim")
end
