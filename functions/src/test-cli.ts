#!/usr/bin/env npx ts-node

const BASE_URL = process.env.API_URL || "http://localhost:6413/demo-janee/us-central1/api";

async function request(method: string, path: string, body?: unknown, apiKey?: string) {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (apiKey) headers["x-api-key"] = apiKey;

  const url = `${BASE_URL}${path}`;
  console.log(`\n${method} ${url}`);

  const res = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  const data = await res.json();
  console.log(`Status: ${res.status}`);
  console.log(JSON.stringify(data, null, 2));
  return data;
}

async function main() {
  const command = process.argv[2];

  switch (command) {
    case "health":
      await request("GET", "/api/health");
      break;

    case "seed":
      await request("POST", "/api/seed");
      break;

    case "list-apps": {
      const apiKey = process.argv[3];
      if (!apiKey) { console.log("Usage: test-cli list-apps <api-key>"); break; }
      await request("GET", "/api/apps?public=true", undefined, apiKey);
      break;
    }

    case "create-app": {
      const apiKey = process.argv[3];
      const name = process.argv[4];
      if (!apiKey || !name) { console.log("Usage: test-cli create-app <api-key> <name>"); break; }
      await request("POST", "/api/apps", { name, isPublic: true }, apiKey);
      break;
    }

    case "add-card": {
      const apiKey = process.argv[3];
      const appId = process.argv[4];
      const title = process.argv[5];
      if (!apiKey || !appId || !title) { console.log("Usage: test-cli add-card <api-key> <app-id> <title>"); break; }
      const desc = process.argv[6] || "";
      await request("POST", `/api/apps/${appId}/cards`, { title, description: desc }, apiKey);
      break;
    }

    case "list-cards": {
      const apiKey = process.argv[3];
      const appId = process.argv[4];
      if (!apiKey || !appId) { console.log("Usage: test-cli list-cards <api-key> <app-id>"); break; }
      await request("GET", `/api/apps/${appId}/cards`, undefined, apiKey);
      break;
    }

    case "decide": {
      const apiKey = process.argv[3];
      const appId = process.argv[4];
      const cardId = process.argv[5];
      const decision = process.argv[6];
      if (!apiKey || !appId || !cardId || !decision) {
        console.log("Usage: test-cli decide <api-key> <app-id> <card-id> <yes|no|skip>");
        break;
      }
      await request("POST", `/api/apps/${appId}/decisions`, { cardId, decision }, apiKey);
      break;
    }

    case "create-key": {
      const apiKey = process.argv[3];
      const appId = process.argv[4];
      if (!apiKey || !appId) { console.log("Usage: test-cli create-key <api-key> <app-id>"); break; }
      await request("POST", "/api/keys", { appId }, apiKey);
      break;
    }

    default:
      console.log(`
JaNee Test CLI

Commands:
  health                                    Check API health
  seed                                      Seed database with sample data
  list-apps <api-key>                       List all public apps
  create-app <api-key> <name>               Create a new app
  add-card <api-key> <app-id> <title> [desc]  Add a card to an app
  list-cards <api-key> <app-id>             List cards in an app
  decide <api-key> <app-id> <card-id> <yes|no|skip>  Make a decision
  create-key <api-key> <app-id>             Create a new API key

Environment:
  API_URL  Override base URL (default: ${BASE_URL})
      `);
  }
}

main().catch(console.error);
