#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/practical/common.sh
source "${SCRIPT_DIR}/common.sh"

STAGE_ARG="${1:-}"
[[ -n "$STAGE_ARG" ]] || die "Usage: deploy-stage.sh <stage-id>   e.g. deploy-stage.sh stage-01"

load_stage_env "$STAGE_ARG"
require_azure_login

[[ -n "${SQL_ADMIN_PASSWORD:-}" ]] || die "SQL_ADMIN_PASSWORD is not set. Export it before deploying."

DEPLOYMENT_NAME="${STAGE_ID}-$(date +%Y%m%d%H%M%S)"

ensure_resource_group "$RG" "$LOCATION"

log "Deploying ${STAGE_TITLE} to resource group '${RG}'."
az deployment group create \
  --resource-group "$RG" \
  --name "$DEPLOYMENT_NAME" \
  --template-file "${REPO_ROOT}/${TEMPLATE_FILE}" \
  --parameters "${REPO_ROOT}/${PARAMETERS_FILE}" \
  --parameters \
      appBaseName="$APP_BASE_NAME" \
      location="$LOCATION" \
      sqlAdministratorLogin="$SQL_ADMIN_LOGIN" \
      sqlAdministratorLoginPassword="$SQL_ADMIN_PASSWORD" \
  --output none

ok "Deployment '${DEPLOYMENT_NAME}' complete."

WEBAPP_URL="$(deployment_output "$RG" "$DEPLOYMENT_NAME" webAppUrl)"
WEBAPP_NAME="$(deployment_output "$RG" "$DEPLOYMENT_NAME" webAppName)"
AI_NAME="$(deployment_output "$RG" "$DEPLOYMENT_NAME" appInsightsName)"

log "Web app:        ${WEBAPP_NAME}"
log "Web app URL:    ${WEBAPP_URL}"
log "App Insights:   ${AI_NAME}"
log "Next: scripts/practical/verify-stage.sh ${STAGE_ARG}"

printf '%s\n' "$DEPLOYMENT_NAME" > "${SCRIPT_DIR}/stages/.${STAGE_ID}.last-deployment"
