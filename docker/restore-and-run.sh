#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${NEO4J_DB_NAME:-neo4j}"

if [[ -n "${NEO4J_RESTORE_DUMP_URL:-}" ]]; then
  if [[ "${NEO4J_FORCE_RESTORE:-false}" == "true" || ! -d "/data/databases/${DB_NAME}" || -z "$(ls -A "/data/databases/${DB_NAME}" 2>/dev/null || true)" ]]; then
    echo ">>> Restoring \"$DB_NAME\" from dump"
    mkdir -p /tmp
    echo ">>> Downloading dump..."
    curl -fsSL "$NEO4J_RESTORE_DUMP_URL" -o "/tmp/${DB_NAME}.dump"
    echo ">>> Loading dump..."
    neo4j-admin database load "$DB_NAME" --from="/tmp/${DB_NAME}.dump" --overwrite-destination=true
    echo ">>> Restore completed"
  else
    echo ">>> Database ${DB_NAME} present; skipping restore (set NEO4J_FORCE_RESTORE=true to overwrite)"
  fi
else
  echo ">>> NEO4J_RESTORE_DUMP_URL not set; skipping restore"
fi

exec /docker-entrypoint.sh neo4j
