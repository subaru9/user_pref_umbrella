defmodule UserPrefWeb.Schema.Middleware.Auth do
  @moduledoc """
  Authenticate user from token
  """

  @spec call(Absinthe.Resolution.t(), term()) :: Absinthe.Resolution.t()
  def call(%{context: %{auth_token: auth_token}} = res, _) when not is_nil(auth_token) do
    case Auth.authenticate(auth_token) do
      {:ok, user_id} ->
        context = Map.put(res.context, :current_user_id, user_id)
        Map.replace(res, :context, context)

      {:error, %ErrorMessage{} = error} ->
        Absinthe.Resolution.put_result(res, {:error, error})
    end
  end

  def call(res, _) do
    error =
      ErrorMessage.unauthorized("[UserPrefWeb.Schema.Middleware.Auth] Unauthorized. Token is missing.")

    Absinthe.Resolution.put_result(res, {:error, error})
  end
end
