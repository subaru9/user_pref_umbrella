## Database Layer

To support the chat functionality, we need to define two main tables:

1. Chats (`chats`) – Stores chat metadata and ensures a unique conversation per user pair.
2. Messages (`chat_messages`) – Stores messages sent within each chat.

### Tables and Fields

### 1. Chats Table (`chats`)

- Stores the metadata of each chat between two users.
- Each chat is unique per user pair (one chat per two users).
- Fields:

  - `id` (integer) – Primary key.
  - `topic` (string) – Unique topic for Absinthe subscriptions.
  - `user_1_id` (foreign key → `users.id`) – First user in the chat.
  - `user_2_id` (foreign key → `users.id`) – Second user in the chat.
  - `inserted_at` (timestamp in UTC, stored in milliseconds) – Time when the chat was created.
  - `updated_at` (timestamp in UTC, stored in milliseconds) – Time when the chat was last updated.

- Indexes and Constraints:
  - Unique constraint on `user_1_id` and `user_2_id` (ensures one chat per user pair).
  - Index on `topic` for efficient subscription lookups.
  - Foreign key constraints on `user_1_id` and `user_2_id` (cascade delete if users are removed).

### 2. Messages Table (`chat_messages`)

- Stores individual chat messages.
- Messages belong to a specific chat and a specific sender.
- Fields:

  - `id` (integer) – Primary key.
  - `chat_id` (foreign key → `chats.id`) – Chat this message belongs to.
  - `sender_id` (foreign key → `users.id`) – User who sent the message.
  - `body` (text) – Message content.
  - `inserted_at` (timestamp in UTC, stored in milliseconds) – When the message was sent.
  - `updated_at` (timestamp in UTC, stored in milliseconds) – When the message was last edited (nullable).

- Indexes and Constraints:
  - Index on `chat_id` (fast message retrieval per chat).
  - Index on `sender_id` (lookup messages by sender).
  - Foreign key constraints on `chat_id` and `sender_id` (cascade delete when a chat or user is removed).

### Table Interconnections

- `chats` connects two users via `user_1_id` and `user_2_id`.
- `chat_messages` belongs to a specific `chat_id` and a specific `sender_id`.
- Each chat has multiple messages, but a message belongs to only one chat.

### What Needs to Be Done

- Create `chats` table with unique user pairs and topic field.
- Create `chat_messages` table with sender, message body, and timestamps.
- Enforce foreign key constraints between chats, messages, and users.
- Index `chat_id` and `topic` for efficient queries.
