#!/usr/bin/env bash
set -euo pipefail

: "${SQL_FQDN:?SQL_FQDN must be set by verify-stage.sh}"
: "${SQL_DB:?SQL_DB must be set by verify-stage.sh}"

if [[ -z "${SQL_ADMIN_LOGIN:-}" || -z "${SQL_ADMIN_PASSWORD:-}" ]]; then
  echo "[warn] SQL_ADMIN_LOGIN/SQL_ADMIN_PASSWORD not set; skipping direct SQL query check." >&2
fi

if command -v sqlcmd >/dev/null 2>&1 && [[ -n "${SQL_ADMIN_LOGIN:-}" && -n "${SQL_ADMIN_PASSWORD:-}" ]]; then
  result="$(sqlcmd -S "tcp:${SQL_FQDN},1433" -d "$SQL_DB" \
    -U "$SQL_ADMIN_LOGIN" -P "$SQL_ADMIN_PASSWORD" \
    -l 30 -h -1 -W -Q "SELECT COUNT(*) FROM sys.tables;" 2>&1)" || {
      echo "[fail] sqlcmd query failed: ${result}" >&2
      exit 1
    }
  echo "[ ok ] SQL reachable on ${SQL_FQDN}; user table count: ${result}"
  exit 0
fi

if command -v nc >/dev/null 2>&1; then
  if nc -z -w 10 "$SQL_FQDN" 1433 >/dev/null 2>&1; then
    echo "[ ok ] TCP 1433 reachable on ${SQL_FQDN} (sqlcmd not installed; connectivity-only check)."
    exit 0
  fi
  echo "[fail] TCP 1433 not reachable on ${SQL_FQDN}." >&2
  exit 1
fi

echo "[warn] Neither sqlcmd nor nc available; cannot verify SQL connectivity." >&2
exit 0
