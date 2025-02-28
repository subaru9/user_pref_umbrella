defmodule UserPrefWeb.Plugs.Auth do
  @moduledoc """
  Forward auth key to Absinthe
  """
  @behaviour Plug

  import Plug.Conn, only: [get_req_header: 2]

  @impl true

  # @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        Absinthe.Plug.assign_context(conn, auth_token: token)

      _ ->
        conn
    end
  end

  @impl true
  def init(_opts), do: :ok
end
