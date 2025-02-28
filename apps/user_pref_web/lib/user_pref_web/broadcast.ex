defmodule UserPrefWeb.Broadcast do
  @moduledoc """
  Handles broadcasting events across the UserPref application.
  """

  @type user_id :: String.t()
  @type auth_token :: String.t()

  @spec publish_new_auth_token(user_id, auth_token) :: :ok
  def publish_new_auth_token(user_id, token) do
    Absinthe.Subscription.publish(
      UserPrefWeb.Endpoint,
      %{token: token},
      new_auth_token: user_id
    )
  end
end
