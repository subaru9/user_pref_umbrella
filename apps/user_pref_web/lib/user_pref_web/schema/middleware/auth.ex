defmodule UserPrefWeb.Schema.Middleware.Auth do
  @moduledoc """
  Verifies auth key
  """

  alias Auth.Token
  alias SharedUtils.Error

  @spec call(Absinthe.Resolution.t(), term()) :: Absinthe.Resolution.t()
  def call(%{context: %{auth_token: auth_token}} = res, _) do
    authenticate_user_from_token(res, auth_token)
  end

  def call(res, _) do
    error = Error.unauthorized("[UserPrefWeb.Schema.Middleware.Auth] Unauthorized. Token is missing.")
    Absinthe.Resolution.put_result(res, {:error, error})
  end

  defp authenticate_user_from_token(res, auth_token) do
    secret = Auth.Config.fetch_secret()

    case Token.validate(auth_token, secret) do
      {:ok, %{"sub" => user_id}} ->
        %{res | context: Map.put(res.context, :current_user_id, user_id)}

      %ErrorMessage{} = error ->
        Absinthe.Resolution.put_result(res, {:error, error})
    end
  end
end
