defmodule GiphyApiTest do
  use ExUnit.Case

  alias GiphyApi.Support.TestHelpers

  describe "&search/1" do
    test "returns expected response for a given query" do
      query = "cat"

      expected_response =
        {:ok,
         [
           %{
             remote_id: "CjmvTCZf2U3p09Cn0h",
             title: "Im Ready Lets Go GIF by Leroy Patterson",
             url: "https://giphy.com/gifs/leroypatterson-cat-glasses-CjmvTCZf2U3p09Cn0h",
             username: "leroypatterson"
           },
           %{
             remote_id: "3oEduQAsYcJKQH2XsI",
             title: "Funny Cat GIF by TJ Fuller",
             url: "https://giphy.com/gifs/cat-lasers-cucumber-3oEduQAsYcJKQH2XsI",
             username: "tjfuller"
           }
         ]}

      HTTPSandbox.set_get_responses([
        # First request (offset: 0, limit: 1)
        {TestHelpers.request_url(query, 0, 1),
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
        # Second request (offset: 1, limit: 1)
        {TestHelpers.request_url(query, 1, 1),
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

      assert GiphyApi.search(query, 2, 1) === expected_response
    end
  end
end
