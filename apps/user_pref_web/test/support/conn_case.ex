defmodule UserPrefWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use UserPrefWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint UserPrefWeb.Endpoint

      use UserPrefWeb, :verified_routes

      # Import conveniences for testing with connections
      import Phoenix.ConnTest, only: [get: 3, post: 3, json_response: 2]
      import Plug.Conn, only: [get_resp_header: 2, put_req_header: 3, delete_req_header: 2]
      import UserPrefWeb.ConnCase, only: [setup_sandbox: 1]

      alias UserPref.Support.Fixtures
    end
  end

  setup tags do
    UserPref.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
  
  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags), do: UserPref.DataCase.setup_sandbox(tags)
end
