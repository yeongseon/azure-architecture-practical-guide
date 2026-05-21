#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PRACTICAL_DIR="$(dirname "$SCRIPT_DIR")"
COMMON_SCRIPT="${PRACTICAL_DIR}/common.sh"
STAGE_ENV_FILE="${1:-${PRACTICAL_DIR}/stages/stage-05.env}"

# shellcheck source=/dev/null
source "$COMMON_SCRIPT"
# shellcheck source=/dev/null
source "$STAGE_ENV_FILE"

validate_az_cli

RG="$(generate_rg_name)"
PRIMARY_WEB_APP_NAME=''
SECONDARY_WEB_APP_NAME=''
PRIMARY_SQL_SERVER_NAME=''
SECONDARY_SQL_SERVER_NAME=''
FAILOVER_GROUP_NAME=''
FRONT_DOOR_PROFILE_NAME=''
FRONT_DOOR_HOST_NAME=''
FAILED_OVER='false'

front_door_ops_info() {
    curl \
        --silent \
        --show-error \
        --write-out $'\n%{http_code}' \
        "https://${FRONT_DOOR_HOST_NAME}/ops/info"
}

wait_for_front_door_region() {
    local expected_region="$1"
    local label="$2"
    local attempt=1

    while [ "$attempt" -le 20 ]; do
        local response
        response="$(front_door_ops_info)"

        local status_code
        status_code="${response##*$'\n'}"

        local response_body
        response_body="${response%$'\n'*}"

        if [ "$status_code" = '200' ] && [[ "$response_body" == *"${expected_region}"* ]]; then
            printf 'PASS: Front Door %s now serves region %s\n' "$label" "$expected_region"
            printf '%s\n' "$response_body"
            return 0
        fi

        printf 'Waiting for Front Door %s. Attempt %s/20, status=%s\n' "$label" "$attempt" "$status_code"
        sleep 20
        attempt=$((attempt + 1))
    done

    printf 'FAIL: Front Door never served region %s during %s\n' "$expected_region" "$label" >&2
    return 1
}

failover_group_show() {
    local server_name

    for server_name in "$PRIMARY_SQL_SERVER_NAME" "$SECONDARY_SQL_SERVER_NAME"; do
        if az sql failover-group show \
            --name "$FAILOVER_GROUP_NAME" \
            --resource-group "$RG" \
            --server "$server_name" \
            --output json >/tmp/stage05-failover-group.json 2>/dev/null; then
            cat /tmp/stage05-failover-group.json
            return 0
        fi
    done

    printf 'FAIL: Unable to query failover group %s\n' "$FAILOVER_GROUP_NAME" >&2
    return 1
}

replication_role_for_server() {
    local server_name="$1"

    az sql failover-group show \
        --name "$FAILOVER_GROUP_NAME" \
        --resource-group "$RG" \
        --server "$server_name" \
        --query replicationRole \
        --output tsv 2>/dev/null || true
}

print_replication_roles() {
    local primary_role
    local secondary_role

    primary_role="$(replication_role_for_server "$PRIMARY_SQL_SERVER_NAME")"
    secondary_role="$(replication_role_for_server "$SECONDARY_SQL_SERVER_NAME")"

    printf 'Primary server candidate %s replicationRole=%s\n' "$PRIMARY_SQL_SERVER_NAME" "${primary_role:-unknown}"
    printf 'Secondary server candidate %s replicationRole=%s\n' "$SECONDARY_SQL_SERVER_NAME" "${secondary_role:-unknown}"
}

wait_for_replication_role_flip() {
    local expected_primary_server="$1"
    local expected_secondary_server="$2"
    local attempt=1

    while [ "$attempt" -le 20 ]; do
        local expected_primary_role
        local expected_secondary_role

        expected_primary_role="$(replication_role_for_server "$expected_primary_server")"
        expected_secondary_role="$(replication_role_for_server "$expected_secondary_server")"

        if [ "$expected_primary_role" = 'Primary' ] && [ "$expected_secondary_role" = 'Secondary' ]; then
            printf 'PASS: SQL failover group roles flipped as expected\n'
            print_replication_roles
            return 0
        fi

        printf 'Waiting for SQL role flip. Attempt %s/20\n' "$attempt"
        sleep 20
        attempt=$((attempt + 1))
    done

    printf 'FAIL: SQL failover group roles did not converge as expected\n' >&2
    print_replication_roles
    return 1
}

cleanup() {
    local cleanup_failed=0

    if [ -n "$PRIMARY_WEB_APP_NAME" ]; then
        printf 'Cleanup: starting primary web app %s\n' "$PRIMARY_WEB_APP_NAME"
        if ! az webapp start --name "$PRIMARY_WEB_APP_NAME" --resource-group "$RG" >/dev/null; then
            cleanup_failed=1
        fi
    fi

    if [ "$FAILED_OVER" = 'true' ] && [ -n "$FAILOVER_GROUP_NAME" ] && [ -n "$PRIMARY_SQL_SERVER_NAME" ]; then
        printf 'Cleanup: failing SQL back to primary server %s\n' "$PRIMARY_SQL_SERVER_NAME"
        if ! az sql failover-group set-primary \
            --name "$FAILOVER_GROUP_NAME" \
            --resource-group "$RG" \
            --server "$PRIMARY_SQL_SERVER_NAME" \
            --try-planned-before-forced-failover >/dev/null 2>&1; then
            if ! az sql failover-group set-primary \
                --name "$FAILOVER_GROUP_NAME" \
                --resource-group "$RG" \
                --server "$PRIMARY_SQL_SERVER_NAME" \
                --allow-data-loss >/dev/null; then
                cleanup_failed=1
            fi
        fi
    fi

    if [ "$cleanup_failed" -ne 0 ]; then
        printf 'WARNING: Cleanup did not complete cleanly. Verify the app and failover group state manually.\n' >&2
    fi
}

trap cleanup EXIT

PRIMARY_WEB_APP_NAME="$({ az webapp list --resource-group "$RG" --query "[?tags.stage=='${STAGE}' && tags.regionRole=='primary'].name | [0]" --output tsv; } 2>/dev/null)"
SECONDARY_WEB_APP_NAME="$({ az webapp list --resource-group "$RG" --query "[?tags.stage=='${STAGE}' && tags.regionRole=='secondary'].name | [0]" --output tsv; } 2>/dev/null)"
PRIMARY_SQL_SERVER_NAME="$({ az sql server list --resource-group "$RG" --query "[?tags.stage=='${STAGE}' && tags.regionRole=='primary'].name | [0]" --output tsv; } 2>/dev/null)"
SECONDARY_SQL_SERVER_NAME="$({ az sql server list --resource-group "$RG" --query "[?tags.stage=='${STAGE}' && tags.regionRole=='secondary'].name | [0]" --output tsv; } 2>/dev/null)"
FRONT_DOOR_PROFILE_NAME="$({ az afd profile list --resource-group "$RG" --query "[?tags.stage=='${STAGE}'].name | [0]" --output tsv; } 2>/dev/null)"
FRONT_DOOR_HOST_NAME="$({ az afd endpoint list --profile-name "$FRONT_DOOR_PROFILE_NAME" --resource-group "$RG" --query "[0].hostName" --output tsv; } 2>/dev/null)"
FAILOVER_GROUP_NAME="$({ az sql failover-group list --resource-group "$RG" --server "$PRIMARY_SQL_SERVER_NAME" --query "[0].name" --output tsv; } 2>/dev/null)"

: "${PRIMARY_WEB_APP_NAME:?Primary web app could not be resolved}"
: "${SECONDARY_WEB_APP_NAME:?Secondary web app could not be resolved}"
: "${PRIMARY_SQL_SERVER_NAME:?Primary SQL server could not be resolved}"
: "${SECONDARY_SQL_SERVER_NAME:?Secondary SQL server could not be resolved}"
: "${FRONT_DOOR_PROFILE_NAME:?Front Door profile could not be resolved}"
: "${FRONT_DOOR_HOST_NAME:?Front Door endpoint could not be resolved}"
: "${FAILOVER_GROUP_NAME:?Failover group could not be resolved}"

printf 'Smoke test resource group: %s\n' "$RG"
printf 'Front Door endpoint: https://%s\n' "$FRONT_DOOR_HOST_NAME"
printf 'Primary web app: %s\n' "$PRIMARY_WEB_APP_NAME"
printf 'Secondary web app: %s\n' "$SECONDARY_WEB_APP_NAME"
printf 'Primary SQL server: %s\n' "$PRIMARY_SQL_SERVER_NAME"
printf 'Secondary SQL server: %s\n' "$SECONDARY_SQL_SERVER_NAME"
printf 'Failover group: %s\n' "$FAILOVER_GROUP_NAME"

initial_response="$(front_door_ops_info)"
initial_status_code="${initial_response##*$'\n'}"
initial_response_body="${initial_response%$'\n'*}"

if [ "$initial_status_code" != '200' ]; then
    printf 'FAIL: Initial Front Door request returned HTTP %s\n' "$initial_status_code" >&2
    exit 1
fi

printf 'PASS: Front Door returned HTTP 200 before failover\n'
printf '%s\n' "$initial_response_body"

printf 'Current SQL failover group replication roles before manual SQL failover\n'
print_replication_roles
failover_group_show

printf 'Triggering SQL failover to secondary server %s\n' "$SECONDARY_SQL_SERVER_NAME"
if az sql failover-group set-primary \
    --name "$FAILOVER_GROUP_NAME" \
    --resource-group "$RG" \
    --server "$SECONDARY_SQL_SERVER_NAME" \
    --try-planned-before-forced-failover >/dev/null 2>&1; then
    true
else
    az sql failover-group set-primary \
        --name "$FAILOVER_GROUP_NAME" \
        --resource-group "$RG" \
        --server "$SECONDARY_SQL_SERVER_NAME" \
        --allow-data-loss >/dev/null
fi

FAILED_OVER='true'

wait_for_replication_role_flip "$SECONDARY_SQL_SERVER_NAME" "$PRIMARY_SQL_SERVER_NAME"

printf 'Stopping primary web app %s to force Front Door failover to secondary region\n' "$PRIMARY_WEB_APP_NAME"
az webapp stop --name "$PRIMARY_WEB_APP_NAME" --resource-group "$RG" >/dev/null

wait_for_front_door_region "$SECONDARY_LOCATION" 'regional failover'

printf 'Stage 5 failover smoke test completed. Cleanup will start the primary app and fail SQL back to the primary region.\n'
