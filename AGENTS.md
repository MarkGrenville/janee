# JaNee — AI Agent Context

## What is JaNee?

JaNee is a Tinder-style yes/no decision app. Users swipe cards to make binary decisions (yes / no / skip). Use cases include wishlists, approvals, date-night ideas, AI-driven workflows, and any scenario where quick binary input is valuable.

## Architecture

Three surfaces share one Firebase backend:

1. **SvelteKit** (`web/`) — Primary web app. Serves the landing page, full authenticated app, and developer documentation. Built with Tailwind CSS.
2. **Flutter** (`app/`) — Mobile companion app. Feature-parity with SvelteKit (minus docs). Optimized for quick swipe sessions.
3. **Cloud Functions** (`functions/`) — TypeScript. HTTP API for CLI/AI integration, Firestore triggers for webhooks and audit trails.

## Key Concepts

- **App**: A collection of cards to swipe on (e.g., "Movie Wishlist", "Boss Approvals"). Can be public or private.
- **Card**: An individual item within an app to make a decision on. Has title, description, optional image/link.
- **Decision**: A user's response to a card: "yes", "no", or "skip". Full audit trail with timing data.
- **Webhook**: Optional HTTP callback fired when a decision is made. Configurable per-app or per-card.
- **API Key**: Authentication for CLI/API access. Scoped to a specific app.

## Tech Stack

- **Frontend (web)**: SvelteKit 2, Tailwind CSS 4, TypeScript
- **Frontend (mobile)**: Flutter/Dart
- **Backend**: Firebase Cloud Functions (Node.js/TypeScript)
- **Database**: Firestore
- **Auth**: Firebase Auth (Email + Google)
- **Storage**: Firebase Storage
- **Hosting**: Firebase Hosting
- **Package manager**: pnpm
- **Process manager**: PM2

## Data Model

See [docs/interfaces-and-models.md](docs/interfaces-and-models.md) for full interface definitions.

### Collections

- `/users/{userId}` — User profile, preferences
- `/users/{userId}/decisions/{decisionId}` — Decision audit trail
- `/users/{userId}/subscriptions/{appId}` — App subscriptions
- `/users/{userId}/friends/{friendId}` — Friend connections
- `/apps/{appId}` — App definitions
- `/apps/{appId}/cards/{cardId}` — Cards within an app
- `/apiKeys/{keyHash}` — API key records

## API

HTTP API served via Cloud Functions. All endpoints prefixed with `/api/`. Authentication via `x-api-key` header for CLI/external access, or Firebase Auth token for web/app access.

Key endpoints:
- `POST /api/apps` — Create app
- `POST /api/apps/:appId/cards` — Add cards
- `GET /api/apps/:appId/decisions` — Get decisions
- `POST /api/keys` — Generate API key

## Firebase Security Rules

- `firestore.rules` — Firestore access control
- `storage.rules` — Storage access control

Rules enforce: users own their data, public apps are readable by authenticated users, private apps restricted to owner/subscribers, decisions are private to the user.

## Port Map

All ports in range 6400-6419. See `wf-ports.json` for full mapping.

| Port | Service |
|------|---------|
| 6400 | SvelteKit dev |
| 6410 | Flutter web dev |
| 6411 | Auth emulator |
| 6412 | Firestore emulator |
| 6413 | Functions emulator |
| 6414 | Hosting emulator |
| 6415 | Storage emulator |
| 6416 | Emulator UI |
| 6417 | Emulator Hub |

## Firebase Project ID

The emulator uses `demo-janee` as the project ID (demo- prefix enables emulator-only mode without a real Firebase account). However, the actual URL path may use whatever project ID the Firebase CLI has active globally. The SvelteKit API client auto-discovers the correct project ID at startup.

## PM2 Naming Convention

All PM2 process names are prefixed with `janee-` for PortIO compatibility:
- `janee-emulators`, `janee-web`, `janee-flutter`, `janee-backup`

## Design System

Editorial luxury aesthetic. See [docs/UXGuidelines.md](docs/UXGuidelines.md) for full tokens.

- Colors: Jet black (#0A0A0A), warm ivory (#FAF8F5), amber accent (#D4A853)
- Typography: Playfair Display (headings), Inter (body)
- Dark mode default, light mode supported

## File Structure Quick Reference

```
janee/
  web/src/routes/(landing)/+page.svelte   # Landing page (all 9 sections)
  web/src/routes/(app)/                    # Authenticated app (swipe, apps, profile, settings, decisions)
  web/src/routes/(docs)/docs/              # Public documentation (API, CLI, guides)
  web/src/routes/login/                    # Login page
  web/src/routes/register/                 # Register page
  web/src/lib/firebase/config.ts           # Firebase client init + emulator connection
  web/src/lib/firebase/api.ts              # API client (wraps Cloud Functions HTTP API)
  web/src/lib/stores/auth.ts               # Auth state (Svelte writable store)
  web/src/lib/stores/theme.ts              # Theme state (dark/light)
  app/lib/main.dart                        # Flutter entry point
  app/lib/config/                          # Firebase config + theme
  app/lib/providers/                       # AuthProvider, AppsProvider (ChangeNotifier)
  app/lib/screens/                         # All Flutter screens
  app/lib/models/                          # AppModel, CardModel, DecisionModel
  functions/src/index.ts                   # Cloud Functions entry (Express app)
  functions/src/api/                       # Route handlers (apps, cards, decisions, keys, users, seed)
  functions/src/triggers/                  # Firestore/Auth triggers (onDecisionCreate, onUserCreate)
  functions/src/types.ts                   # Shared TypeScript interfaces
  functions/src/utils/auth.ts              # Auth middleware (API key + Bearer token)
  functions/src/utils/webhook.ts           # Webhook firing utility
  functions/src/test-cli.ts                # CLI for testing API endpoints
```

## Conventions

- TypeScript everywhere (functions + SvelteKit)
- Thorough `console.log` / `print()` for debugging via `pm2 logs`
- pnpm for Node.js dependencies
- All scripts in `scripts/`
- Documentation in `docs/`
- Svelte 5 runes mode ($state, $derived, $effect, $props)
- Flutter uses Provider for state management
- Express params use `param()` helper for type safety (Express 5)
- Firebase Functions v1 compat for Firestore/Auth triggers
