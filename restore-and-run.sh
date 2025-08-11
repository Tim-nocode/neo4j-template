#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${NEO4J_DB_NAME:-neo4j}"
DUMP_URL="${NEO4J_RESTORE_DUMP_URL:-}"
FORCE="${NEO4J_FORCE_RESTORE:-false}"
MARKER="/data/.restored_${DB_NAME}"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

restore_needed() {
  if [[ "${FORCE}" == "true" ]]; then return 0; fi
  if [[ ! -d "/data/databases/${DB_NAME}" ]]; then return 0; fi
  if [[ -z "$(ls -A "/data/databases/${DB_NAME}" 2>/dev/null || true)" ]]; then return 0; fi
  if [[ ! -f "${MARKER}" ]]; then return 0; fi
  return 1
}

if [[ -n "${DUMP_URL}" ]] && restore_needed; then
  log ">>> Restoring \"${DB_NAME}\" from dump"
  mkdir -p /tmp
  log ">>> Downloading dump..."
  curl -fsSL "${DUMP_URL}" -o "/tmp/${DB_NAME}.dump"

  log ">>> Loading dump..."
  neo4j-admin database load "${DB_NAME}" --from-path="/tmp" --overwrite-destination=true

  touch "${MARKER}"
  log ">>> Restore completed"
else
  if [[ -z "${DUMP_URL}" ]]; then
    log ">>> NEO4J_RESTORE_DUMP_URL not set; skipping restore"
  else
    log ">>> Database ${DB_NAME} already present; skipping restore (set NEO4J_FORCE_RESTORE=true to overwrite)"
  fi
fi

# Для отладки — где лежит бинарь
command -v neo4j || true

# Запуск сервера в foreground (правильно для Docker)
exec neo4j console
