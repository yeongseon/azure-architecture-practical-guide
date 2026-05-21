#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
COMMON_SCRIPT="${SCRIPT_DIR}/common.sh"
VERIFY_DIR="${SCRIPT_DIR}/verify"
STAGE_ENV_FILE="${1:?Usage: bash scripts/practical/verify-stage.sh <stage-env-file>}"

# shellcheck source=/dev/null
source "$COMMON_SCRIPT"
# shellcheck source=/dev/null
source "$STAGE_ENV_FILE"

validate_az_cli

RG="$(generate_rg_name)"
export RG
export APP_NAME
export STAGE

# Discover resource names from the deployed resource group.
# Bicep generates names with uniqueString so we query Azure to find them.
discover_resource_name() {
    local resource_type="$1"
    local query="${2:-[0].name}"
    az resource list \
        --resource-group "$RG" \
        --resource-type "$resource_type" \
        --query "$query" \
        --output tsv 2>/dev/null || true
}

WEB_APP_NAME="$(discover_resource_name 'Microsoft.Web/sites' "[?tags.stage=='${STAGE}'].name | [0]")"
if [ -z "$WEB_APP_NAME" ]; then
    WEB_APP_NAME="$(discover_resource_name 'Microsoft.Web/sites')"
fi
export WEB_APP_NAME

SQL_SERVER_NAME="$(discover_resource_name 'Microsoft.Sql/servers' "[?tags.stage=='${STAGE}'].name | [0]")"
if [ -z "$SQL_SERVER_NAME" ]; then
    SQL_SERVER_NAME="$(discover_resource_name 'Microsoft.Sql/servers')"
fi
export SQL_SERVER_NAME

SQL_DATABASE_NAME="$(az sql db list --resource-group "$RG" --server "$SQL_SERVER_NAME" --query "[?name!='master'].name | [0]" --output tsv 2>/dev/null || true)"
export SQL_DATABASE_NAME

if [ -n "${SECONDARY_LOCATION:-}" ]; then
    export SECONDARY_LOCATION
fi

printf 'Discovered resources in %s:\n' "$RG"
printf '  WEB_APP_NAME=%s\n' "${WEB_APP_NAME:-<not found>}"
printf '  SQL_SERVER_NAME=%s\n' "${SQL_SERVER_NAME:-<not found>}"
printf '  SQL_DATABASE_NAME=%s\n' "${SQL_DATABASE_NAME:-<not found>}"

verify_scripts=()

case "$STAGE" in
    stage-01-mvp)
        verify_scripts=(
            "${VERIFY_DIR}/http-smoke.sh"
            "${VERIFY_DIR}/sql-smoke.sh"
        )
        ;;
    stage-02-production-baseline)
        verify_scripts=(
            "${VERIFY_DIR}/http-smoke.sh"
            "${VERIFY_DIR}/sql-smoke.sh"
        )
        ;;
    stage-03-scale-edge)
        verify_scripts=(
            "${VERIFY_DIR}/http-smoke.sh"
            "${VERIFY_DIR}/sql-smoke.sh"
            "${VERIFY_DIR}/frontdoor-smoke.sh"
        )
        ;;
    stage-04-network-isolation)
        verify_scripts=(
            "${VERIFY_DIR}/http-smoke.sh"
            "${VERIFY_DIR}/frontdoor-smoke.sh"
            "${VERIFY_DIR}/private-connectivity-smoke.sh"
        )
        ;;
    stage-05-resilience)
        verify_scripts=(
            "${VERIFY_DIR}/http-smoke.sh"
            "${VERIFY_DIR}/frontdoor-smoke.sh"
            "${VERIFY_DIR}/failover-smoke.sh"
        )
        ;;
    *)
        printf 'ERROR: No verify script set is defined for %s\n' "$STAGE" >&2
        exit 1
        ;;
esac

pass_count=0
fail_count=0

for verify_script in "${verify_scripts[@]}"; do
    printf '\n--- Running %s ---\n' "$(basename "$verify_script")"
    if bash "$verify_script"; then
        pass_count=$((pass_count + 1))
    else
        fail_count=$((fail_count + 1))
    fi
done

printf '\nVerification summary for %s: %s passed, %s failed\n' "$STAGE" "$pass_count" "$fail_count"

if [ "$fail_count" -gt 0 ]; then
    exit 1
fi
