defmodule UserPrefWeb.Schema.Mutation.UserPref do
  @moduledoc """
  Mutations for the UserPref context
  """
  use Absinthe.Schema.Notation

  alias UserPrefWeb.Resolvers.UserPref

  object :user_mutations do
    @desc "Creates user"
    field :create_user, :user do
      arg :input, :user_with_pref_input
      resolve &UserPref.create_user/2
    end

    @desc "Updates user"
    field :update_user, :user do
      arg :input, :user_input
      resolve &UserPref.update_user/2
    end
  end

  object :pref_mutations do
    @desc "Updates user's preferences"
    field :update_pref, :pref do
      arg :input, :update_pref_input
      resolve &UserPref.update_pref/2
    end
  end
end
