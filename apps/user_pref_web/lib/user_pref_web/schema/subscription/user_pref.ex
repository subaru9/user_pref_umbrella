defmodule UserPrefWeb.Schema.Subscription.UserPref do
  @moduledoc """
  Subscriptions for the UserPref context
  """
  use Absinthe.Schema.Notation
  require Logger

  object :user_subscriptions do
    @desc "Enable to receive user data if user is created"
    field :user_created, :user do
      config fn _field_args, _resolution ->
        {:ok, topic: "user_created"}
      end

      resolve fn user, _field_args, _resolution ->
        {:ok, user}
      end

      trigger :create_user,
        topic: fn _user -> "user_created" end
    end

    @desc "Enable to receive preferences if user preferences are updated"
    field :pref_updated, :pref do
      arg :user_id, non_null(:id)

      config fn field_args, _resolution ->
        {:ok, topic: field_args.user_id}
      end

      resolve fn pref, _field_args, _resolution ->
        {:ok, pref}
      end

      trigger :update_pref,
        topic: fn pref -> pref.user_id end
    end

    @desc "Will receive token in user_id topic on :user_auth_token event"
    field :new_auth_token, :string do
      arg :user_id, non_null(:id)

      config fn args, _info ->
        Logger.debug("Configuring subscription for topic: #{args.user_id}")
        {:ok, topic: args.user_id}
      end

      resolve fn %{token: token}, _args, _info ->
        Logger.debug("Resolving subscription with token: #{token}")
        {:ok, token}
      end
    end
  end
end
