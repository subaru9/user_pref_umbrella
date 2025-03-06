defmodule Auth do
  @moduledoc """
  Behaviour for authentication.
  """
  @type auth_token :: String.t() | nil
  @type user_id :: non_neg_integer
  @type res :: ErrorMessage.t_res(user_id)

  @doc """
  Verify credentials and store current user id in a context
  """
  @callback authenticate(auth_token) :: res

  alias Auth.{Config, Token}

  @behaviour Auth

  @impl Auth
  @spec authenticate(auth_token()) :: res
  def authenticate(auth_token) do
    with secret <- Config.fetch_secret(),
         {:ok, %{"sub" => user_id}} <- Token.validate(auth_token, secret) do
      {:ok, user_id}
    end
  end
end
