<p align="center">
  <h1 align="center">JaNee</h1>
  <p align="center"><strong>Your life, one swipe at a time.</strong></p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
  <img src="https://img.shields.io/badge/Firebase-ffca28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/SvelteKit-FF3E00?logo=svelte&logoColor=white" alt="SvelteKit" />
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
</p>

---

JaNee is a Tinder-style yes/no decision interface. Create collections of cards — movie picks, hire approvals, date-night ideas, AI-generated options — and swipe through them to make fast, binary decisions. Every swipe is logged with timing data, and webhooks can fire downstream actions the moment a decision lands.

Decision fatigue is real. The average adult makes 35,000 decisions per day, and most of them don't need a meeting, a spreadsheet, or an hour-long debate. JaNee reduces every choice to its essence: **yes** or **no**. It's designed to make decisions fun, fast, and final — whether you're picking a movie, approving a hire, or giving AI-generated content the human sign-off it needs.

From personal wishlists and wedding planning to team approval queues and fully automated AI workflows, JaNee works wherever quick binary input is valuable. Build public polls for your community, create private approval flows for your team, or wire up the CLI to pipe GPT outputs into swipeable cards. It's decisions, simplified.

## Features

- **Swipe interface** — yes, no, or skip on every card
- **Custom apps with cards** — create collections for any decision scenario
- **Public and private apps** — share with the world or keep it to your team
- **Webhook integration** — fire HTTP callbacks on every decision for real-time notifications
- **CLI and API** — automate card creation and decision retrieval for AI/automation workflows
- **Decision audit trail** — full history with timing data on every swipe
- **Public profiles and friends** — connect with others and share apps
- **Dark/light mode** — editorial luxury aesthetic with Playfair Display and Inter
- **Cross-platform** — SvelteKit web app + Flutter mobile companion

## Screenshots

<!-- TODO: Add screenshots of the swipe interface, app creation, and CLI usage -->
![Swipe Interface](docs/screenshots/swipe.png)
![App Dashboard](docs/screenshots/dashboard.png)
![CLI Usage](docs/screenshots/cli.png)

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
# Clone the repository
git clone https://github.com/janee-app/janee.git
cd janee

# Install dependencies
(cd functions && pnpm install)
(cd web && pnpm install)

# Start the full dev environment
pm2 start ecosystem.config.cjs

# Seed the database with sample data
bash scripts/seed.sh

# View logs
pm2 logs
```

Once running, open [http://localhost:6400](http://localhost:6400) for the web app and [http://localhost:6416](http://localhost:6416) for the Firebase Emulator UI.

## Architecture

JaNee has three surfaces that share a single Firebase backend:

| Surface | Directory | Description |
|---|---|---|
| **SvelteKit** | `web/` | Primary web app — landing page, full authenticated experience, and developer documentation |
| **Flutter** | `app/` | Mobile companion app — feature-parity with the web app, optimized for quick swipe sessions |
| **Cloud Functions** | `functions/` | TypeScript HTTP API for CLI/AI integration, Firestore triggers for webhooks and audit trails |

All three connect to Firebase Auth, Firestore, and Storage. In development, they point at the local Firebase emulator suite.

## Documentation

| Resource | URL |
|---|---|
| Full documentation | [`/docs`](http://localhost:6400/docs) |
| API Reference | [`/docs/api`](http://localhost:6400/docs/api) |
| CLI Guide | [`/docs/cli`](http://localhost:6400/docs/cli) |
| Guides (Webhooks, etc.) | [`/docs/guides`](http://localhost:6400/docs/guides) |

## API

All API endpoints are served via Cloud Functions and prefixed with `/api/`. Authenticate with an `x-api-key` header or a Firebase Auth bearer token.

**Create an app:**

```bash
curl -X POST http://localhost:6413/api/apps \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{
    "name": "Movie Night",
    "description": "What should we watch?",
    "isPublic": true
  }'
```

**Add a card:**

```bash
curl -X POST http://localhost:6413/api/apps/APP_ID/cards \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{
    "title": "The Grand Budapest Hotel",
    "description": "Wes Anderson, 2014"
  }'
```

See the [API Reference](http://localhost:6400/docs/api) for all available endpoints.

## Port Map

All ports are in the 6400–6419 range.

| Port | Service |
|---|---|
| 6400 | SvelteKit dev server |
| 6410 | Flutter web dev server |
| 6411 | Auth emulator |
| 6412 | Firestore emulator |
| 6413 | Functions emulator |
| 6414 | Hosting emulator |
| 6415 | Storage emulator |
| 6416 | Emulator UI |
| 6417 | Emulator Hub |

## Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes and ensure they work with the emulator suite
4. Commit with a descriptive message (`git commit -m "Add my feature"`)
5. Push to your fork (`git push origin feature/my-feature`)
6. Open a Pull Request

Please keep PRs focused and include a clear description of what changed and why. For larger changes, open an issue first to discuss the approach.

## License

This project is licensed under the [MIT License](LICENSE).
