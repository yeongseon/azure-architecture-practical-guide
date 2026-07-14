#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/practical/common.sh
source "${SCRIPT_DIR}/common.sh"

STAGE_ARG="${1:-}"
[[ -n "$STAGE_ARG" ]] || die "Usage: destroy-stage.sh <stage-id>   e.g. destroy-stage.sh stage-01"

load_stage_env "$STAGE_ARG"
require_azure_login

if ! az group show --resource-group "$RG" >/dev/null 2>&1; then
  warn "Resource group '${RG}' does not exist. Nothing to destroy."
  exit 0
fi

log "Deleting resource group '${RG}' (all ${STAGE_TITLE} resources)."
az group delete --resource-group "$RG" --yes --no-wait
ok "Delete requested for '${RG}'. Azure will remove resources in the background."

rm -f "${SCRIPT_DIR}/stages/.${STAGE_ID}.last-deployment"
