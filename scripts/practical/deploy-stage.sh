#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
COMMON_SCRIPT="${SCRIPT_DIR}/common.sh"
STAGE_ENV_FILE="${1:?Usage: bash scripts/practical/deploy-stage.sh <stage-env-file>}"

# shellcheck source=/dev/null
source "$COMMON_SCRIPT"
# shellcheck source=/dev/null
source "$STAGE_ENV_FILE"

validate_az_cli

RG="$(generate_rg_name)"

COST_ESTIMATES=(
    "stage-01-mvp:~\$0.10/h"
    "stage-02-production-baseline:~\$0.17/h"
    "stage-03-scale-edge:~\$0.25/h"
    "stage-04-network-isolation:~\$0.30/h"
    "stage-05-resilience:~\$0.60/h"
)

cost_estimate="unknown"
for entry in "${COST_ESTIMATES[@]}"; do
    if [[ "$entry" == "${STAGE}:"* ]]; then
        cost_estimate="${entry#*:}"
        break
    fi
done

print_cost_warning "$cost_estimate"

printf 'Creating resource group %s in %s\n' "$RG" "$LOCATION"
az group create --name "$RG" --location "$LOCATION"

DEPLOY_PARAMS=(
    --resource-group "$RG"
    --template-file "$BICEP_FILE"
    --parameters "$PARAM_FILE"
    --parameters "appName=${APP_NAME}"
)

if [ -n "${SQL_ADMIN_LOGIN:-}" ]; then
    DEPLOY_PARAMS+=(--parameters "sqlAdminLogin=${SQL_ADMIN_LOGIN}")
fi

if [ -n "${SQL_ADMIN_PASSWORD:-}" ]; then
    DEPLOY_PARAMS+=(--parameters "sqlAdminPassword=${SQL_ADMIN_PASSWORD}")
fi

if [ -n "${ALERT_EMAIL:-}" ]; then
    DEPLOY_PARAMS+=(--parameters "alertEmail=${ALERT_EMAIL}")
fi

if [ -n "${SECONDARY_LOCATION:-}" ]; then
    DEPLOY_PARAMS+=(--parameters "secondaryLocation=${SECONDARY_LOCATION}")
fi

printf 'Deploying %s with template %s\n' "$STAGE" "$BICEP_FILE"
az deployment group create "${DEPLOY_PARAMS[@]}"

printf 'Deployment finished for %s\n' "$STAGE"
