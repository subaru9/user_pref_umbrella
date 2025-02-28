defmodule UserPrefWeb.Resolvers.Tokens do
  @moduledoc """
  Resolvers for the Auth.Tokens context
  """

  @type user :: UserPref.User.t()
  @type res :: Absinthe.Resolution.t()
  @type auth_token :: String.t()
  @type error :: {:error, SharedUtils.Error.t()}

  @spec get(user, map, res) :: {:ok, auth_token} | error 
  def get(user, _attrs, _res) do
    Auth.Tokens.get(%{id: user.id})
  end
end
