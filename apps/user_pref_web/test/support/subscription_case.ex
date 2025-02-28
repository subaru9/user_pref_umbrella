defmodule UserPrefWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  subscription tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ConnTest, only: [post: 3, json_response: 2]
      import Plug.Conn, only: [put_req_header: 3]

      use UserPrefWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: UserPrefWeb.Schema

      import UserPref.Support.Fixtures, only: [user_fixture: 1]

      setup do
        UserPref.DataCase.setup_sandbox(async: true)
        {:ok, socket} = Phoenix.ChannelTest.connect(UserPrefWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        conn = Phoenix.ConnTest.build_conn()

        {:ok, socket: socket, conn: conn}
      end
    end
  end
end
