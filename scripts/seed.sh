#!/usr/bin/env bash
set -euo pipefail

FUNCTIONS_HOST="http://localhost:6413"
API_BASE="${FUNCTIONS_HOST}/janee-dev/us-central1/api"

echo "[janee-seed] Seeding emulator database..."
echo "[janee-seed] Functions endpoint: $API_BASE"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$FUNCTIONS_HOST" 2>/dev/null || echo "000")
if [[ "$RESPONSE" == "000" ]]; then
  echo "[janee-seed] ERROR: Functions emulator not reachable. Start emulators first."
  exit 1
fi

echo "[janee-seed] Calling seed endpoint..."
curl -s -X POST "${API_BASE}/seed" \
  -H "Content-Type: application/json" | jq . 2>/dev/null || echo "(raw response above)"

echo ""
echo "[janee-seed] Seeding complete."
