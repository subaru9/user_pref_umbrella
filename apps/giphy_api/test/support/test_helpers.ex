defmodule GiphyApi.Support.TestHelpers do
  @moduledoc """
  Test helpers for GiphyApi.
  """
  def mock_giphy_responses(first_name) do
    HTTPSandbox.set_get_responses([
      {request_url(first_name, 0, 15),
       fn ->
         {:ok,
          %{
            :data => [
              %{
                id: "CjmvTCZf2U3p09Cn0h",
                title: "Im Ready Lets Go GIF by Leroy Patterson",
                url: "https://giphy.com/gifs/leroypatterson-cat-glasses-CjmvTCZf2U3p09Cn0h",
                username: "leroypatterson"
              }
            ]
          }}
       end},
      {request_url(first_name, 15, 15),
       fn ->
         {:ok,
          %{
            :data => [
              %{
                id: "3oEduQAsYcJKQH2XsI",
                title: "Funny Cat GIF by TJ Fuller",
                url: "https://giphy.com/gifs/cat-lasers-cucumber-3oEduQAsYcJKQH2XsI",
                username: "tjfuller"
              }
            ]
          }}
       end}
    ])
  end

  @spec request_url(String.t(), non_neg_integer(), non_neg_integer()) :: String.t()
  def request_url(query, offset, limit) do
    params =
      URI.encode_query(%{
        "api_key" => GiphyApi.Config.api_key!(),
        "q" => query,
        "limit" => limit,
        "offset" => offset
      })

    GiphyApi.Config.base_url!() <> "/v1/gifs/search?" <> params
  end
end
