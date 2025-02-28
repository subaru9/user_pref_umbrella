defmodule SharedUtils.Redis.Pool do
  def child_spec(opts) do
    pool_name = Map.fetch!(opts, :pool_name)
    registration_scope = Map.get(opts, :registration_scope, :local)
    pool_size = Map.get(opts, :pool_size, 10)
    max_overflow = Map.get(opts, :max_overflow, 10)
    strategy = Map.get(opts, :strategy, :lifo)

    :poolboy.child_spec(
      pool_name,
      name: {registration_scope, pool_name},
      worker_module: Redix,
      size: pool_size,
      max_overflow: max_overflow,
      strategy: strategy
    )
  end

  def execute_transaction(pool_name, command, on_success) do
    :poolboy.transaction(pool_name, fn pid ->
      case Redix.command(pid, command) do
        {:ok, result} -> on_success.(result)
        {:error, reason} -> {:error, SharedUtils.ErrorConverter.to_error(reason)}
      end
    end)
  end
end
