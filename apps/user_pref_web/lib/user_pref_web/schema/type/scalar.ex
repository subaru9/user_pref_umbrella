defmodule UserPrefWeb.Schema.Type.Scalar do
  @moduledoc """
  Scalar types
  """

  use Absinthe.Schema.Notation

  scalar :utc_datetime_usec, description: "ISO8601 UTC DateTime with microsecond precision" do
    parse fn input ->
      case DateTime.from_iso8601(input) do
        {:ok, dt, _offset} -> {:ok, DateTime.shift_zone!(dt, "Etc/UTC")}
        _ -> :error
      end
    end

    serialize fn datetime ->
      datetime
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_iso8601(:extended)
    end
  end
end
