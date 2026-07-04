#!/usr/bin/env bash
set -euo pipefail

EXPECTED_PROJECT="demo-janee"
CURRENT_PROJECT=$(firebase use 2>/dev/null | grep -oP '(?<=Active Project: )\S+' || echo "")

if [[ -z "$CURRENT_PROJECT" ]]; then
  CURRENT_PROJECT=$(cat .firebaserc 2>/dev/null | grep -oP '"default":\s*"\K[^"]+' || echo "")
fi

if [[ "$CURRENT_PROJECT" != "$EXPECTED_PROJECT" ]]; then
  echo "ERROR: Active Firebase project is '$CURRENT_PROJECT', expected '$EXPECTED_PROJECT'."
  echo "Run: firebase use $EXPECTED_PROJECT"
  exit 1
fi

echo "Deploying to project: $EXPECTED_PROJECT"

echo "Building SvelteKit..."
(cd web && pnpm run build)

echo "Building Cloud Functions..."
(cd functions && pnpm run build)

echo "Deploying hosting, functions, firestore rules, and storage rules..."
firebase deploy --only hosting,functions,firestore:rules,storage

echo "Deploy complete."
