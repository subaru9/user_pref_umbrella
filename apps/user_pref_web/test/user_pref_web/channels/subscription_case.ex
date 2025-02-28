defmodule UserPrefWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  subscription tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Plug.Conn
      import Phoenix.ConnTest

      use UserPrefWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: UserPrefWeb.Schema

      import UserPref.Support.Fixtures, only: [user_fixture: 1]

      setup do
        UserPrefWeb.ConnCase.setup_sandbox(async: true)
        {:ok, socket} = Phoenix.ChannelTest.connect(UserPrefWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, socket: socket}
      end
    end
  end
end
