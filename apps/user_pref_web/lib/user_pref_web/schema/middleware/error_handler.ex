defmodule UserPrefWeb.Schema.Middleware.ErrorHandler do
  @moduledoc """
  Finetune errors for Absinthe's Resolution result
  """
  @behaviour Absinthe.Middleware

  alias SharedUtils.Error

  @impl true
  @spec call(Absinthe.Resolution.t(), term) :: Absinthe.Resolution.t()
  def call(res, _) do
    error_message =
      Enum.reduce(res.errors, nil, fn
        %ErrorMessage{details: %Ecto.Changeset{} = changeset}, acc ->
          case find_matching_error(changeset.errors) do
            {:conflict, field_name, error_message} ->
              Error.conflict("#{field_name} #{error_message}", %{field_name => error_message})

            {:bad_request, field_name, error_message} ->
              acc ||
                Error.bad_request("#{field_name} #{error_message}", %{field_name => error_message})
          end

        error_message = %ErrorMessage{}, _acc ->
          error_message

        _, _acc ->
          Error.internal_server_error("Unexpected error")
      end)

    if error_message do
      error = ErrorMessage.to_jsonable_map(error_message)
      Absinthe.Resolution.put_result(res, {:error, error})
    else
      res
    end
  end

  defp find_matching_error(errors) do
    Enum.find_value(errors, fn
      {field_name, {error_message, [{:constraint, :unique}, _]}} ->
        {:conflict, field_name, error_message}

      {field_name, {error_message, _}} ->
        {:bad_request, field_name, error_message}

      _ ->
        nil
    end)
  end
end
