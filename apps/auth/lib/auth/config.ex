defmodule Auth.Config do
  def tokens do
    Map.merge(
      Application.fetch_env!(:auth, :tokens),
      Application.fetch_env!(:auth, :tokens_runtime)
    )
  end

  def fetch_secret, do: Map.fetch!(tokens(), :secret)
  def debug, do: Map.fetch!(tokens(), :debug)
end
