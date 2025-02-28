defmodule SharedUtils.ErrorConverter do
  @moduledoc """
  Converts various error structures into consistent `ErrorMessage.t()` format.
  """

  @spec to_error(Redix.ConnectionError.t()) :: ErrorMessage.t()
  @spec to_error(Redix.Error.t()) :: ErrorMessage.t()
  @spec to_error(any()) :: ErrorMessage.t()
  def to_error(%{__struct__: Redix.ConnectionError, reason: reason}) do
    SharedUtils.Error.internal_server_error("Redis connection error", %{reason: reason})
  end

  def to_error(%{__struct__: Redix.Error, message: message}) do
    SharedUtils.Error.internal_server_error("Redis command error", %{message: message})
  end

  def to_error(other) do
    SharedUtils.Error.internal_server_error("Unknown error", %{error: other})
  end
end
