defmodule UserPrefWeb.Schema.Type.UserPref do
  @moduledoc """
  Types for the UserPref context
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias UserPrefWeb.Resolvers.Tokens

  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :auth_token, :string, resolve: &Tokens.get/3
    # Dataloader batches user_id collection during user resolution.
    # Once all user_ids are known, it queries the UserPref source 
    # registered in context/1 to efficiently fetch prefs for all users in a single query.
    field :pref, :pref, resolve: dataloader(UserPref)
    field :avatars, list_of(:avatar), resolve: dataloader(UserPref)
  end

  object :pref do
    field :user_id, :id
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end

  object :avatar do
    field :title, :string
    field :url, :string
    field :username, :string
    field :remote_id, :string
    field :user_id, :id
  end

  input_object :user_input do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
  end

  input_object :pref_input do
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end

  input_object :user_with_pref_input do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :pref, :pref_input
  end

  input_object :update_pref_input do
    field :user_id, non_null(:id)
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end
end
