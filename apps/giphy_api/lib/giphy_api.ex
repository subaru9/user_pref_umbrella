defmodule GiphyApi do
  @request_timeout 2000
  @remote_id_key :remote_id
  @fields [@remote_id_key, :url, :username, :title]

  alias SharedUtils.JSON
  alias GiphyApi.{Config, TaskSupervisor}

  @doc """
  By default fetches 30 gifs using HTTP/2 multiplexing,
  by firing 2 unlinked supervised tasks and yield for results

  ## Example

      iex> GiphyApi.search("cat", 2, 1)
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
       ]
      }
  """
  def search(query, total_count \\ 30, batch_size \\ 15) do
    url = "#{Config.base_url!()}/v1/gifs/search?"

    if Config.current_env() === :test do
      query
      |> build_requests(url, total_count, batch_size)
      |> Enum.map(&HTTPSandbox.get_response(&1, [], []))
      |> process_results(query, url)
    else
      query
      |> build_requests(url, total_count, batch_size)
      |> spawn_tasks()
      |> process_results(query, url)
    end
  end

  defp build_requests(query, url, total_count, batch_size) do
    for {offset, limit} <- generate_batches(total_count, batch_size) do
      params =
        URI.encode_query(%{
          "api_key" => Config.api_key!(),
          "offset" => offset,
          "limit" => limit,
          "q" => query
        })

      full_url = url <> params

      if Config.current_env() === :test do
        full_url
      else
        Finch.build(:get, full_url)
      end
    end
  end

  defp generate_batches(total_count, batch_size) do
    0..(total_count - 1)
    |> Stream.chunk_every(batch_size)
    |> Stream.map(&{List.first(&1), length(&1)})
  end

  defp spawn_tasks(requests) do
    for request <- requests do
      Task.Supervisor.async_nolink(TaskSupervisor, fn ->
        Finch.request(request, GiphyApiFinch)
      end)
    end
  end

  defp process_results(tasks_or_responses, query, url) do
    if Config.current_env() === :test do
      {successes, errors} =
        Enum.split_with(tasks_or_responses, &match?({:ok, _}, &1))

      successes
      |> normalize_responses()
      |> extract_gifs()
      |> format_results(normalize_responses(errors))
    else
      {successes, errors} =
        tasks_or_responses
        |> Stream.map(&await_task(&1, query, url))
        |> Enum.split_with(&match?({:ok, _}, &1))

      successes
      |> normalize_responses()
      |> extract_gifs()
      |> format_results(normalize_responses(errors))
    end
  end

  defp format_results(successes, errors) do
    case {Enum.to_list(successes), Enum.to_list(errors)} do
      {[], errors} -> {:error, errors}
      {successes, []} -> {:ok, successes}
      {successes, errors} -> {:ok, successes, errors}
    end
  end

  defp extract_gifs(successes) do
    successes
    |> Stream.flat_map(&Map.fetch!(&1, :data))
    |> Stream.map(fn gif ->
      gif
      |> Map.put(@remote_id_key, gif.id)
      |> Map.take(@fields)
    end)
  end

  defp normalize_responses(responses) do
    Stream.map(responses, fn
      {:ok, value} -> value
      {:error, error} -> error
    end)
  end

  defp await_task(task, query, url) do
    case Task.yield(task, @request_timeout) do
      nil ->
        _ = Task.shutdown(task)

        {:error,
         ErrorMessage.request_timeout(
           "Request didn't completed in #{@request_timeout} ms",
           %{task: task}
         )}

      {:exit, reason} ->
        {:error,
         ErrorMessage.internal_server_error(
           "Request task has exited with rearon #{reason}",
           %{task: task}
         )}

      {:ok, result} ->
        handle_response(result, url <> "q=#{query}")
    end
  end

  defp handle_response({:ok, %Finch.Response{status: status, body: body}}, _url)
       when status in 200..299 do
    JSON.decode(body)
  end

  defp handle_response({:error, %{__exception__: true} = exception}, url) do
    {:error,
     ErrorMessage.internal_server_error(
       Exception.message(exception),
       %{endpoint: url, exception: exception}
     )}
  end

  defp handle_response({:error, error}, url) do
    {:error, ErrorMessage.internal_server_error(inspect(error), %{endpoint: url})}
  end
end
