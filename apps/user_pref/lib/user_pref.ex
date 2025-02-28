defmodule UserPref do
  @moduledoc """
  Access layer for schemas.

  Benefits of returning ErrorMessage: uniformity, reusability, extensibility, testability.
  """

  alias EctoShorts.Actions
  alias EctoShorts.Actions.QueryBuilder
  alias SharedUtils.Error
  alias UserPref.{Avatar, Pref, Repo, User}

  @type user :: User.t()
  @type pref :: Pref.t()
  @type avatar :: Avatar.t()
  @type error :: {:error, Error.t()}
  @type users :: list(user) | list()
  @type user_params :: User.params_t()
  @type pref_params :: Pref.params_t()
  @type avatar_params :: Avatar.params_t()
  @type id :: String.t()
  @type data_loader :: Dataloader.Ecto.t()

  @type filter_params ::
          %{
            optional(:likes_emails) => boolean(),
            optional(:likes_faxes) => boolean(),
            optional(:likes_phone_calls) => boolean()
          }
          | %{optional(atom()) => any()}
          | keyword(any())

  @behaviour QueryBuilder

  @impl QueryBuilder
  def filters, do: [:likes_emails, :likes_faxes, :likes_phone_calls]

  @impl QueryBuilder
  def build_query(User, %{likes_emails: val}, query), do: Pref.likes_emails_query(val, query)

  @impl QueryBuilder
  def build_query(User, %{likes_faxes: val}, query), do: Pref.likes_faxes_query(val, query)

  @impl QueryBuilder
  def build_query(User, %{likes_phone_calls: val}, query),
    do: Pref.likes_phone_calls_query(val, query)

  @spec users(filter_params()) :: users
  def users(params \\ %{}, opts \\ []) do
    Actions.all(User.join_pref(), params, opts)
  end

  @spec get_user(id) :: {:ok, user} | error
  def get_user(id) do
    case Actions.get(User, id) do
      nil -> {:error, Error.not_found("not found", %{id: id})}
      user = %User{} -> {:ok, user}
    end
  end

  @spec create_user(user_params()) :: {:ok, user} | error
  def create_user(params) do
    with {:error, changeset = %Ecto.Changeset{}} <-
           %User{} |> User.changeset(params) |> Repo.insert() do
      {:error, Error.unprocessable_entity("invalid request data", changeset)}
    end
  end

  @spec create_avatar(avatar_params) :: {:ok, avatar} | error
  def create_avatar(params) do
    with {:error, changeset = %Ecto.Changeset{}} <- Actions.create(Avatar, params) do
      {:error, Error.unprocessable_entity("invalid request data", changeset)}
    end
  end

  @spec update_user(user_params) :: {:ok, user} | error
  def update_user(params \\ %{}) do
    with {:ok, id} <- Map.fetch(params, :id),
         {:ok, %User{} = user} <- get_user(id),
         {:error, changeset = %Ecto.Changeset{}} <-
           user |> User.changeset(params) |> Repo.update() do
      {:error, Error.unprocessable_entity("invalid request data", changeset)}
    end
  end

  @spec update_pref(pref_params) :: {:ok, pref} | error
  def update_pref(params) when params === %{} do
    {:error, Error.unprocessable_entity("invalid request data", %{params: params})}
  end

  def update_pref(params) do
    with {:error, changeset = %Ecto.Changeset{}} <-
           Actions.find_and_update(Pref, %{user_id: params[:user_id]}, params) do
      {:error, Error.unprocessable_entity("invalid request data", changeset)}
    end
  end

  @spec create_many(module(), [map()], keyword()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def create_many(schema_module, entities, opts \\ []) do
    entities
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {entity, index}, multi ->
      Ecto.Multi.insert(
        multi,
        "create_many_#{Macro.underscore(schema_module)}_#{index}",
        fn _ ->
          schema_module.create_changeset(entity)
        end,
        opts
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _res} = result ->
        result

      {:error, operation, changeset, _multi_changes} ->
        {:error, ErrorMessage.unprocessable_entity("Failed to #{operation}", changeset)}
    end
  end

  @doc """
  Defines a `Dataloader.Ecto` source for batch-loading database records.

  - Instantiates a `Dataloader.Ecto` source connected to `Repo`.
  - Applies an optional query function (`query/2`) for customizing queries.
  - Registers this source in `context/1` for use in GraphQL resolvers.

  - Enables `Dataloader` to batch-load records efficiently, preventing N+1 queries.
  - Provides a seamless bridge between GraphQL resolvers and the database.
  """
  @spec datasource :: data_loader
  def datasource, do: Dataloader.Ecto.new(Repo, query: &query/2)

  # Query function for `Dataloader.Ecto`, allowing pre-processing before execution.
  #
  # - Currently acts as a pass-through (`queryable` is returned unchanged).
  # - Serves as a placeholder for applying custom filters or query modifications.
  #
  # - Passed as `query: &query/2` in `datasource/0`, allowing customization.
  # - Can be modified to apply additional constraints, such as filtering by status.
  #
  # ### Example: Filtering for active preferences
  # ```elixir
  # defp query(queryable, _), do: from(q in queryable, where: q.active == true)
  # ```
  defp query(queryable, _), do: queryable
end
