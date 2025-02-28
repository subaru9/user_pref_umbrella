defmodule UserPrefWeb.Schema.Middleware.Debug do
  @moduledoc """
  Debugging info on Absinthe level
  """
  @behaviour Absinthe.Middleware

  @spec call(Absinthe.Resolution.t(), atom() | {atom(), String.t()}) :: Absinthe.Resolution.t()
  def call(resolution, :start) do
    path = resolution |> Absinthe.Resolution.path() |> Enum.join(".")

    IO.puts("""
    ======================
    starting: #{path}
    with source: #{inspect(resolution.source)}\
    """)

    %{resolution | middleware: resolution.middleware ++ [{__MODULE__, {:finish, path}}]}
  end

  def call(resolution, {:finish, path}) do
    IO.puts("""
    completed: #{path}
    value: #{inspect(resolution.value)} ======================\
    """)

    resolution
  end
end
