defmodule SharedUtils.Error do
  @moduledoc """
  wrapper for errors compatible
  with graphql resolvers, logger, etc.
  """

  @type t :: ErrorMessage.t()

  @http_error_codes [
    :bad_request,
    :conflict,
    :internal_server_error,
    :not_acceptable,
    :not_found,
    :unauthorized,
    :unprocessable_entity
  ]

  for func_name <- @http_error_codes do
    @doc """
    Creates ErrorMessage struct from args

    ## Examples

        iex> SharedUtils.Error.#{func_name}("Resource not found", %{resource_id: 123})
        %ErrorMessage{
          type: :#{func_name},
          message: "Resource not found",
          details: %{resource_id: 123}
        }
    """
    @spec unquote(func_name)(message :: String.t(), details :: any) :: t
    def unquote(func_name)(message, details \\ %{}) do
      apply(ErrorMessage, unquote(func_name), [message, details])
    end
  end
end
