## GraphQL API Layer

We need to expose the following GraphQL operations to handle chat functionality:

### 1. **Types**

- **ChatMessage** – Represents a message within a chat.
  - `id` (ID)
  - `chatId` (ID)
  - `senderId` (ID)
  - `body` (String)
  - `insertedAt` (Timestamp in milliseconds)
  - `updatedAt` (Timestamp in milliseconds)

### 2. Mutations

- **Send a message** – Create and store a new message in the chat.

### 3. Subscriptions

- **Listen for a new message** – Subscribe to real-time updates for incoming messages.
