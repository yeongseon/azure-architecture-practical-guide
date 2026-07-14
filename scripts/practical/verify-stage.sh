#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/practical/common.sh
source "${SCRIPT_DIR}/common.sh"

STAGE_ARG="${1:-}"
[[ -n "$STAGE_ARG" ]] || die "Usage: verify-stage.sh <stage-id>   e.g. verify-stage.sh stage-01"

load_stage_env "$STAGE_ARG"
require_azure_login

LAST_DEPLOYMENT_FILE="${SCRIPT_DIR}/stages/.${STAGE_ID}.last-deployment"
[[ -f "$LAST_DEPLOYMENT_FILE" ]] || die "No recorded deployment for ${STAGE_ID}. Run deploy-stage.sh first."
DEPLOYMENT_NAME="$(cat "$LAST_DEPLOYMENT_FILE")"

WEBAPP_URL="$(deployment_output "$RG" "$DEPLOYMENT_NAME" webAppUrl)"
WEBAPP_NAME="$(deployment_output "$RG" "$DEPLOYMENT_NAME" webAppName)"
SQL_FQDN="$(deployment_output "$RG" "$DEPLOYMENT_NAME" sqlServerFqdn)"
SQL_DB="$(deployment_output "$RG" "$DEPLOYMENT_NAME" sqlDatabaseName)"

export WEBAPP_URL WEBAPP_NAME SQL_FQDN SQL_DB RG

failures=0
for smoke in "${VERIFY_SCRIPTS[@]}"; do
  smoke_path="${SCRIPT_DIR}/verify/${smoke}"
  [[ -x "$smoke_path" ]] || smoke_path="bash ${SCRIPT_DIR}/verify/${smoke}"
  log "Running smoke test: ${smoke}"
  if bash "${SCRIPT_DIR}/verify/${smoke}"; then
    ok "${smoke} passed."
  else
    err "${smoke} failed."
    failures=$((failures + 1))
  fi
done

if [[ "$failures" -gt 0 ]]; then
  die "${failures} smoke test(s) failed for ${STAGE_TITLE}."
fi
ok "${STAGE_TITLE} verification passed."
