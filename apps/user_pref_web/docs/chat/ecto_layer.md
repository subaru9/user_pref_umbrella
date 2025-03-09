## Ecto Layer

To implement the database structure, we need two Ecto schemas:

1. `Chat` – Represents a conversation between two users.
2. `ChatMessage` – Represents messages within a chat.

### 1. Chat Schema (`Chat`)

- Represents a chat between two users.
- Fields:

  - `id` (integer) – Primary key.
  - `topic` (string) – Unique chat identifier.
  - `user_1_id` (foreign key → `users.id`).
  - `user_2_id` (foreign key → `users.id`).
  - `inserted_at` (timestamp in UTC, stored in milliseconds).
  - `updated_at` (timestamp in UTC, stored in milliseconds).

- Constraints:
  - Unique constraint on `user_1_id` and `user_2_id`.
  - Foreign key constraints on `user_1_id` and `user_2_id`.

### 2. ChatMessage Schema (`ChatMessage`)

- Represents a message in a chat.
- Fields:

  - `id` (integer) – Primary key.
  - `chat_id` (foreign key → `chats.id`).
  - `sender_id` (foreign key → `users.id`).
  - `body` (text).
  - `inserted_at` (timestamp in UTC, stored in milliseconds).
  - `updated_at` (timestamp in UTC, stored in milliseconds).

- Constraints:
  - Foreign key constraints on `chat_id` and `sender_id`.

### Table Interconnections

- `Chat` connects two users via `user_1_id` and `user_2_id`.
- `ChatMessage` belongs to `chat_id` and `sender_id`.

### What Needs to Be Done

- Define `Chat` and `ChatMessage` schemas with the required fields.
- Enforce unique and foreign key constraints.
- Index `chat_id` and `topic` for efficient queries.
