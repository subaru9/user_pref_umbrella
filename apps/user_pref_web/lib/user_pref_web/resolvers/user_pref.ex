defmodule UserPrefWeb.Resolvers.UserPref do
  @moduledoc """
  Resolvers for the UserPref context
  """

  alias UserPrefWeb.Resolvers.UserAvatarsWorker

  @type user :: UserPref.User.t()
  @type pref :: UserPref.Pref.t()
  @type res :: Absinthe.Resolution.t()
  @type error :: {:error, SharedUtils.Error.t()}
  @type users :: list(user) | list()

  @spec users(map, res) :: {:ok, users}
  def users(params, _resolution) do
    {:ok, UserPref.users(params, query_builder: UserPref)}
  end

  @spec get_user(map, res) :: {:ok, user} | error
  def get_user(params, _resolution) do
    UserPref.get_user(params[:id])
  end

  @spec create_user(map, res) :: {:ok, user} | error
  def create_user(%{input: attrs}, _resolution) do
    with {:ok, user} <- UserPref.create_user(attrs),
         {:ok, _job} <- UserAvatarsWorker.enqueue(user.id, user.first_name) do
      {:ok, user}
    end
  end

  @spec update_user(map, res) :: {:ok, user} | error
  def update_user(%{input: attrs}, _resolution) do
    UserPref.update_user(attrs)
  end

  @spec update_pref(%{:input => map}, res) :: {:ok, pref} | error
  def update_pref(%{input: attrs}, _resolution) do
    UserPref.update_pref(attrs)
  end

  @spec get_current_user(map, res) :: {:ok, user} | error
  def get_current_user(_params, %{context: %{current_user_id: user_id}})
      when not is_nil(user_id) do
    UserPref.get_user(user_id)
  end

  def get_current_user(_params, _resolution),
    do: ErrorMessage.unauthorized("[UserPrefWeb.Resolvers.UserPref] Unauthorized. No current user found.")
end
