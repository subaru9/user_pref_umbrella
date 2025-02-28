defmodule BgJobs do
  @moduledoc """
  Dedicated sub-application and node for executing long-running, heavy jobs.
  """

  @in_progress_states [:available, :scheduled, :executing]

  @doc """
  Returns the job states that indicate an in-progress job.

  Used to enforce uniqueness in Oban.

  ## Examples

      iex> BgJobs.in_progress_states()
      [:available, :scheduled, :executing]

  """
  def in_progress_states, do: @in_progress_states
end
