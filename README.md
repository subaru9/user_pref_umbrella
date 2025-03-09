## User Preferences Umbrella Demo

This project showcases a distributed web application architecture with:

- **Authentication** for GraphQL endpoints.
- **Oban as a dedicated service** with failover support.
- **A remote API client** that makes parallel asynchronous requests.
- **A GraphQL API** for structured queries, mutations, and subscriptions.
- **Request caching** to optimize performance.
- **Prometheus and Grafana metrics** for monitoring and observability.

### Sub-Applications

- **[Auth](./apps/auth/README.md)** – Manages JWT token creation and validation, with a GenStage pipeline to pre-generate and cache tokens in ETS.
- **[BgJobs](./apps/bg_jobs/README.md)** – Runs an Oban worker that monitors node status, tracks online nodes, and sends metrics to Grafana.
- **[GiphyAPI](./apps/giphy_api/README.md)** – Fetches GIFs from the Giphy API using supervised, unlinked async tasks and processes JSON with Elixir’s native support.
- **[SharedUtils](./apps/shared_utils/README.md)** – Provides a cacheable behavior with implementations for Agents, ETS, and GenServer, along with Redis caching and JSON utilities.
- **[Support](./apps/support/README.md)** – Offers configuration helpers for loading settings and generating secrets for development.
- **[UserPref](./apps/user_pref/README.md)** – Defines **Ecto schemas** and database access using **EctoShorts**, including custom filters contributed upstream.
- **[UserPrefWeb](./apps/user_pref_web/README.md)** – Implements the **GraphQL API**, including authenticated mutations, request caching with Redis, resolver hit tracking, and Prometheus metrics for Grafana visualization.

## Chat System Documentation

For details on the chat implementation using Absinthe GraphQL subscriptions, see the **specifications document**:

- **[Chat Specs](./apps/user_pref_web/docs/chat/specs.md)**

### License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
