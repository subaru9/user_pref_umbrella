defmodule Auth.Tokens do
  @moduledoc """
  The Tokens context is responsible for managing user authentication tokens,
  including creating, refreshing, and caching tokens.
  """

  alias Auth.Tokens.Cache
  alias Auth.Token
  alias SharedUtils.Error

  require Logger

  @type user_id :: String.t() | integer()
  @type ttl :: integer()
  @type secret :: String.t()
  @type exp_time :: integer()
  @type auth_token :: String.t()
  @type error :: {:error, Error.t()}
  @type token_tuple :: {auth_token, exp_time}
  @type token_map :: %{key: user_id, val: token_tuple}
  @type config :: %{ttl: ttl, secret: secret}

  @spec create(user_id, ttl, secret) :: token_tuple
  def create(user_id, ttl, secret) do
    new_exp_time = current_time() + ttl
    new_token = Token.create(%{"sub" => user_id, "exp" => new_exp_time}, secret)

    {new_token, new_exp_time}
  end

  @spec get(%{id: user_id}) :: {:ok, auth_token} | error
  def get(%{id: user_id}) do
    case get(user_id) do
      {token, _exp_time} ->
        {:ok, token}

      nil ->
        {:error, Error.not_found("auth token not found", %{user_id: user_id})}
    end
  end

  @spec get(user_id) :: token_tuple | nil
  defdelegate get(user_id), to: Cache

  @spec put(%{key: user_id, val: token_tuple}) :: :ok
  def put(%{key: user_id, val: {new_token, new_exp_time}}) do
    Cache.put(user_id, {new_token, new_exp_time})
  end

  @spec refresh(user_id, config) :: token_map | nil
  def refresh(user_id, %{ttl: ttl, secret: secret}) do
    now = current_time()

    case get(user_id) do
      {_token, exp_time} when exp_time < now ->
        %{key: user_id, val: create(user_id, ttl, secret)}

      nil ->
        %{key: user_id, val: create(user_id, ttl, secret)}

      _ ->
        if Auth.Config.debug() do
          Logger.debug("[Tokens] auth token refresh skipped, user_id: #{user_id}")
        end

        nil
    end
  end

  defp current_time, do: :os.system_time(:seconds)

end
