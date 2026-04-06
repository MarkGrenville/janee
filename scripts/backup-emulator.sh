#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "$0")/.." && pwd)/emulator-data"
HUB_HOST="localhost"
HUB_PORT=6417
INTERVAL_SECONDS=180

echo "[janee-backup] Emulator backup daemon started (interval: ${INTERVAL_SECONDS}s)"
echo "[janee-backup] Backup dir: $BACKUP_DIR"

while true; do
  sleep "$INTERVAL_SECONDS"

  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://${HUB_HOST}:${HUB_PORT}/emulators" 2>/dev/null || echo "000")

  if [[ "$RESPONSE" == "200" ]]; then
    echo "[janee-backup] $(date '+%Y-%m-%d %H:%M:%S') Exporting emulator data..."
    EXPORT_RESPONSE=$(curl -s -w "%{http_code}" -X POST "http://${HUB_HOST}:${HUB_PORT}/emulators/export" \
      -H "Content-Type: application/json" \
      -d "{\"path\": \"${BACKUP_DIR}\"}" 2>/dev/null || echo "000")
    echo "[janee-backup] Export response: $EXPORT_RESPONSE"
  else
    echo "[janee-backup] $(date '+%Y-%m-%d %H:%M:%S') Emulator hub not reachable (status: $RESPONSE), skipping backup."
  fi
done
