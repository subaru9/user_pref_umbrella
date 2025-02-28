defmodule UserPrefWeb.Schema.Query.UserPref do
  @moduledoc """
  Queries for the UserPref context
  """
  use Absinthe.Schema.Notation

  alias UserPrefWeb.Resolvers.UserPref

  object :user_queries do
    @desc "Get users by their preferences"
    field :users, list_of(:user) do
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean
      arg :before, :id
      arg :after, :id
      arg :first, :id
      resolve &UserPref.users/2
    end

    @desc "Get a user by id"
    field :user, :user do
      arg :id, non_null(:id)
      resolve &UserPref.get_user/2
    end

    @desc "Get the currently authenticated user"
    field :current_user, :user do
      resolve &UserPref.get_current_user/2
    end
  end
end
