# JaNee

A Tinder-style yes/no decision app. Swipe to decide — build wishlists, approve ideas, manage AI-powered workflows, and more.

## Architecture

- **SvelteKit** (`web/`) — Primary web app: landing page, full app experience, documentation
- **Flutter** (`app/`) — Mobile companion app optimized for quick swipe sessions
- **Cloud Functions** (`functions/`) — TypeScript API, webhooks, Firestore triggers
- **Firebase** — Auth, Firestore, Storage, Hosting, Emulators

## Quick Start

### Prerequisites

- Node.js 18+
- pnpm (`npm i -g pnpm`)
- Firebase CLI (`npm i -g firebase-tools`)
- Flutter SDK
- PM2 (`npm i -g pm2`)
- Java 11+ (for Firebase emulators)

### Setup

```bash
# Install all dependencies
(cd functions && pnpm install)
(cd web && pnpm install)

# Start the full dev environment
pm2 start ecosystem.config.cjs

# View logs
pm2 logs

# Seed the database with sample data
bash scripts/seed.sh
```

### Development URLs

| Service | URL |
|---|---|
| SvelteKit Web App | http://localhost:6400 |
| Flutter Web | http://localhost:6410 |
| Firebase Emulator UI | http://localhost:6416 |
| Functions API | http://localhost:6413 |

### PM2 Processes

| Process | Description |
|---|---|
| `janee-emulators` | Firebase emulators with auto-import/export |
| `janee-web` | SvelteKit dev server (port 6400) |
| `janee-flutter` | Flutter web dev server (port 6410) |
| `janee-backup` | Periodic emulator data backup (every 3 min) |

### Scripts

- `scripts/deploy.sh` — Deploy to Firebase (verifies project first)
- `scripts/backup-emulator.sh` — Emulator backup daemon
- `scripts/seed.sh` — Seed database with sample data

## Documentation

- [Interfaces & Models](docs/interfaces-and-models.md)
- [UX Guidelines](docs/UXGuidelines.md)
- [AGENTS.md](AGENTS.md) — AI context for Cursor sessions

## Port Allocation

All ports in the 6400-6419 range. See `wf-ports.json` for the full map.
