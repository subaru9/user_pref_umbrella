defmodule Support.Config do
  @app :support

  def current_env, do: Application.fetch_env!(@app, :env)
  def current_target, do: Application.fetch_env!(@app, :target)
end
