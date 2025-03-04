defmodule Config.RuntimeSchema do
  import Confispex.Schema, only: [defvariables: 1, validate_variables!: 1]
  alias Confispex.Type

  @behaviour Confispex.Schema

  defvariables(%{
    "AUTH_TOKEN_TTL_SEC" => %{
      doc: "JWT's TTL in seconds",
      cast: {Type.Integer, scope: :positive},
      groups: [:auth],
      required: [:auth],
      default_lazy: fn
        %{env: :prod} -> "86400"
        %{env: :dev} -> "600"
        %{env: :test} -> "60"
      end
    },
    "AUTH_TOKEN_SECRET" => %{
      doc: "Secret for JWT's signature",
      cast: Type.String,
      groups: [:auth],
      required: [:auth],
      template_value_generator: fn ->
        Support.ConfigUtils.generate_or_load_secret("auth_token_secret.txt")
      end
    },
    "AUTH_TOKEN_DEBUG" => %{
      doc: "Enables logging",
      cast: Type.Boolean,
      groups: [:auth],
      default_lazy: fn
        %{env: :prod} -> "false"
        %{env: :dev} -> "true"
        %{env: :test} -> "true"
      end
    },
    "GIPHY_API_KEY" => %{
      doc: "Allows access to Giphy Api",
      cast: Type.String,
      groups: [:giphy],
      required: [:giphy],
      template_value_generator: fn ->
        Support.ConfigUtils.load_secret("giphy_api_key.txt")
      end
    },
    "GIPHY_API_POOL_SIZE" => %{
      doc: "Number of connections",
      cast: {Type.Integer, scope: :positive},
      groups: [:giphy],
      required: [:giphy],
      default_lazy: fn _ -> "50" end
    },
    "GIPHY_API_POOL_COUNT" => %{
      doc: "Number of pools",
      cast: {Type.Integer, scope: :positive},
      groups: [:giphy],
      required: [:giphy],
      default_lazy: fn _ -> "1" end
    },
    "PRIMARY_DB_URL"=> %{
      doc: "Primary db url: ecto://USER:PASS@HOST/DATABASE",
      cast: Type.URL,
      groups: [:primary_db],
      required: [:primary_db],
      aliases: ["DATABASE_URL"],
      context: [env: [:prod]]
    },
    "PRIMARY_DB_POOL_SIZE"=> %{
      doc: "Number of open connnections to primary db",
      cast: Type.Integer,
      groups: [:primary_db],
      required: [:primary_db],
      aliases: ["POOL_SIZE"],
      context: [env: [:prod]],
      default_lazy: fn _ -> "10" end
    },
    "ECTO_IPV6" => %{
      doc: "Enebles IPV6",
      cast: Type.Boolean,
      groups: [:primary_db],
      default: "false",
      context: [env: [:prod]]
    },
    "OBAN_DB_URL"=> %{
      doc: "Oban db url: ecto://USER:PASS@HOST/DATABASE",
      cast: Type.URL,
      groups: [:oban_db],
      required: [:oban_db],
      aliases: ["OBAN_DATABASE_URL"],
      context: [env: [:prod]]
    },
    "OBAN_DB_POOL_SIZE"=> %{
      doc: "Number of open connnections to oban db",
      cast: Type.Integer,
      groups: [:oban_db],
      required: [:oban_db],
      aliases: ["OBAN_POOL_SIZE"],
      context: [env: [:prod]],
      default_lazy: fn _ -> "10" end
    },
    "SECRET_KEY_BASE" => %{
      doc: "Used to sign/encrypt cookies and other secrets",
      cast: Type.String,
      groups: [:http_endpoint],
      required: [:http_endpoint],
      context: [env: [:prod]],
      template_value_generator: fn ->
        Support.ConfigUtils.generate_or_load_secret("secret_key_base.txt")
      end
    },
    "PORT" => %{
      doc: "Network port on which web server listens for incoming HTTP requests",
      cast: Type.String,
      groups: [:http_endpoint],
      required: [:http_endpoint],
      context: [env: [:prod]],
      default_lazy: fn _ -> "4000" end
    }
  })
end
