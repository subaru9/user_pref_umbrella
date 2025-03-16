defmodule Support.ConfigUtils do
  def generate_or_load_secret(filename) do
    path = Path.expand("config/secrets/#{filename}")

    case File.read(path) do
      {:ok, secret} -> String.trim(secret)
      {:error, _} -> generate_and_store_secret(path)
    end
  end

  def load_secret(filename) do
    path = Path.expand("config/secrets/#{filename}")

    case File.read(path) do
      {:ok, secret} ->
        String.trim(secret)

      {:error, reason} ->
        {:error,
         ErrorMessage.not_found("[Support.ConfigUtils] secret file not found. #{reason}", path)}
    end
  end

  defp generate_and_store_secret(path) do
    secret = random_string(64)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, secret <> "\n")
    secret
  end

  defp random_string(length) when length > 31 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode64(padding: false)
    |> binary_part(0, length)
  end
end
