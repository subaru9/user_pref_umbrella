defmodule UserPrefWeb.Router do
  use UserPrefWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug,
      schema: UserPrefWeb.Schema,
      before_send: {RequestCache, :connect_absinthe_context_to_conn}

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: UserPrefWeb.Schema,
      interface: :playground
  end
end
