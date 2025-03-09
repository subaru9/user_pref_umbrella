# Specs for User Chat Based on GraphQL Subscriptions

When one user wants to chat with another, **we need**:

- **Find or create a singleton chat** for the two users to ensure they have a dedicated conversation.
- **Fetch the messages** of that chat from the database to provide chat history.
- **Respond to the user** with the paginated chat history so they can see past messages.
- **Subscribe the user to the chat** via an Absinthe subscription.
- **When a new message is sent**, it is published to the subscription topic of a chat.
- **Absinthe pushes the new message** to all subscribed clients using Phoenix Channels.

## Related Documentation

- [Database Layer](./database_layer.md)
- [Ecto Layer](./ecto_layer.md)
- [Ecto Queries Layer](./ecto_shorts_layer.md)
- [GraphQL API Layer](./graphql_api_level.md)
