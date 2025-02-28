defmodule UserPref.Support.Fixtures do
  @moduledoc """
  Fixtures for testing
  """
  alias UserPref.User

  @spec user_fixture(User.params_t()) :: User.t()
  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    first_name = attrs[:first_name] || "user-#{unique_id}"
    last_name = attrs[:last_name] || "test"
    email = attrs[:email] || "#{first_name}.#{last_name}@example.com"

    default_attrs = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      pref: %{
        likes_emails: false,
        likes_phone_calls: false,
        likes_faxes: false
      }
    }

    merged_attrs = Map.merge(default_attrs, attrs)

    {:ok, user} = UserPref.create_user(merged_attrs)

    user
  end
end
