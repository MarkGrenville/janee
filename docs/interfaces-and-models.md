# JaNee — Interfaces & Models

This document defines the data models (Firestore documents) and API request/response shapes used across the JaNee codebase. Both the SvelteKit frontend and Flutter app consume these same structures.

Source of truth: [`functions/src/types.ts`](../functions/src/types.ts)

---

## Enums / Union Types

| Type | Values | Description |
|------|--------|-------------|
| `ResponseType` | `"yes_no"`, `"multiple_choice"`, `"free_text"` | Type of response a card accepts. Only `yes_no` in phase 1. |
| `DecisionValue` | `"yes"`, `"no"`, `"skip"` | User's response to a card. |
| `FriendStatus` | `"pending"`, `"accepted"`, `"blocked"` | State of a friend connection. |
| `CardStatus` | `"active"`, `"archived"` | Whether a card is currently swipeable. |

---

## Firestore Documents

### UserDoc — `/users/{userId}`

| Field | Type | Description |
|-------|------|-------------|
| `displayName` | string | User's display name |
| `email` | string | Email address |
| `photoURL` | string | Profile photo URL |
| `publicProfile` | boolean | Whether profile is visible to others |
| `bio` | string | Short bio |
| `createdAt` | Timestamp | Account creation time |
| `updatedAt` | Timestamp | Last profile update |

### AppDoc — `/apps/{appId}`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | App display name |
| `description` | string | What this app is about |
| `icon` | string | Emoji or icon identifier |
| `imageUrl` | string | Cover image URL |
| `coverColor` | string | Hex color for card backgrounds |
| `ownerId` | string | User ID of the creator |
| `isPublic` | boolean | Discoverable by all users |
| `responseType` | ResponseType | Type of decisions (yes_no for now) |
| `webhookUrl` | string | Default webhook URL for all cards |
| `subscriberCount` | number | Number of subscribers |
| `createdAt` | Timestamp | Creation time |
| `updatedAt` | Timestamp | Last update |

### CardDoc — `/apps/{appId}/cards/{cardId}`

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Card headline |
| `subtitle` | string | Secondary label (e.g., category) |
| `description` | string | Detailed description |
| `imageUrl` | string | Card image |
| `linkUrl` | string | External link for more info |
| `icon` | string | Emoji or icon |
| `status` | CardStatus | active or archived |
| `webhookUrl` | string | Per-card webhook override |
| `metadata` | map | Flexible key-value data |
| `createdAt` | Timestamp | When the card was created |
| `availableSince` | Timestamp | When the card became available for swiping |
| `createdBy` | string | User ID or API key identifier |

### DecisionDoc — `/users/{userId}/decisions/{decisionId}`

| Field | Type | Description |
|-------|------|-------------|
| `appId` | string | Which app this decision belongs to |
| `cardId` | string | Which card was decided on |
| `cardTitle` | string | Denormalized card title for display |
| `decision` | DecisionValue | yes, no, or skip |
| `decidedAt` | Timestamp | When the decision was made |
| `availableSince` | Timestamp | When the card became available |
| `timeToDecisionMs` | number | Milliseconds between available and decided |
| `webhookFired` | boolean | Whether webhook was called |
| `webhookResponse` | map \| null | Webhook response data |
| `webhookFiredAt` | Timestamp \| null | When webhook was fired |

### SubscriptionDoc — `/users/{userId}/subscriptions/{appId}`

| Field | Type | Description |
|-------|------|-------------|
| `subscribedAt` | Timestamp | When the user subscribed |
| `notifications` | boolean | Whether to receive notifications |

### FriendDoc — `/users/{userId}/friends/{friendId}`

| Field | Type | Description |
|-------|------|-------------|
| `status` | FriendStatus | pending, accepted, or blocked |
| `initiatedBy` | string | User ID who sent the request |
| `since` | Timestamp | Connection timestamp |

### ApiKeyDoc — `/apiKeys/{keyHash}`

| Field | Type | Description |
|-------|------|-------------|
| `userId` | string | Owner of the key |
| `appId` | string | Which app the key is for |
| `label` | string | Human-readable label |
| `keyPrefix` | string | First 10 chars of the key (for display) |
| `permissions` | string[] | Allowed operations |
| `createdAt` | Timestamp | When the key was created |
| `lastUsedAt` | Timestamp \| null | Last API call with this key |

---

## API Request Shapes

### CreateAppRequest

```typescript
{
  name: string;          // required
  description?: string;
  icon?: string;
  imageUrl?: string;
  coverColor?: string;
  isPublic?: boolean;    // default: false
  responseType?: ResponseType;  // default: "yes_no"
  webhookUrl?: string;
}
```

### CreateCardRequest

```typescript
{
  title: string;         // required
  subtitle?: string;
  description?: string;
  imageUrl?: string;
  linkUrl?: string;
  icon?: string;
  webhookUrl?: string;
  metadata?: Record<string, unknown>;
}
```

Cards can be created individually or as an array (batch).

### CreateDecisionRequest

```typescript
{
  cardId: string;        // required
  decision: "yes" | "no" | "skip";  // required
}
```

### CreateApiKeyRequest

```typescript
{
  appId: string;         // required
  label?: string;        // default: "Default"
  permissions?: string[];  // default: ["read", "write"]
}
```

---

## API Response Shape

All endpoints return:

```typescript
{
  success: boolean;
  data?: T;         // Present on success
  error?: string;   // Present on failure
}
```

---

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/health` | None | Health check |
| POST | `/api/seed` | None | Seed database (dev only) |
| GET | `/api/apps` | Required | List apps (query: `?public=true`) |
| POST | `/api/apps` | Required | Create app |
| GET | `/api/apps/:appId` | Required | Get app details |
| PUT | `/api/apps/:appId` | Owner | Update app |
| DELETE | `/api/apps/:appId` | Owner | Delete app |
| POST | `/api/apps/:appId/subscribe` | Required | Subscribe to app |
| DELETE | `/api/apps/:appId/subscribe` | Required | Unsubscribe |
| GET | `/api/apps/:appId/cards` | Required | List cards (query: `?status=active`) |
| GET | `/api/apps/:appId/cards/undecided` | Required | Get undecided cards for user |
| POST | `/api/apps/:appId/cards` | Owner | Add card(s) |
| PUT | `/api/apps/:appId/cards/:cardId` | Owner | Update card |
| POST | `/api/apps/:appId/decisions` | Required | Create decision |
| GET | `/api/apps/:appId/decisions` | Required | List decisions (query: `?decision=yes&limit=50`) |
| POST | `/api/keys` | Required | Create API key |
| GET | `/api/keys` | Required | List API keys |
| DELETE | `/api/keys/:keyId` | Owner | Delete API key |
| GET | `/api/users/me` | Required | Get own profile |
| PUT | `/api/users/me` | Required | Update own profile |
| GET | `/api/users/:userId` | Required | Get user profile (public fields only if not public) |
| POST | `/api/users/friends/:friendId` | Required | Send friend request |
| PUT | `/api/users/friends/:friendId/accept` | Required | Accept friend request |

### Authentication

Two methods:
1. **API Key**: `x-api-key: jn_...` header — for CLI/AI integrations
2. **Bearer Token**: `Authorization: Bearer <firebase-id-token>` — for web/app clients
