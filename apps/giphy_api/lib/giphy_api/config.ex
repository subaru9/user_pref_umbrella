defmodule GiphyApi.Config do
  @app :giphy_api

  def api_key!, do: Application.fetch_env!(@app, :api_key)
  def search_limit!, do: Application.fetch_env!(@app, :search_limit)
  def base_url!, do: Application.fetch_env!(@app, :base_url)
  def pools!, do: Application.fetch_env!(@app, :pools)
end
