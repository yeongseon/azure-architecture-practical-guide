#!/usr/bin/env bash

set -euo pipefail

: "${RG:?RG must be exported before running frontdoor-smoke.sh}"
: "${APP_NAME:?APP_NAME must be exported before running frontdoor-smoke.sh}"

failure_count=0

discover_name() {
    local resource_type="$1"
    local query="[?starts_with(name, '${APP_NAME}')].name | [0]"

    az resource list \
        --resource-group "$RG" \
        --resource-type "$resource_type" \
        --query "$query" \
        --output tsv
}

profile_name="${FRONT_DOOR_PROFILE_NAME:-$(discover_name 'Microsoft.Cdn/profiles')}"
endpoint_name="${FRONT_DOOR_ENDPOINT_NAME:-$(az afd endpoint list --profile-name "$profile_name" --resource-group "$RG" --query '[0].name' --output tsv)}"
endpoint_host="${FRONT_DOOR_ENDPOINT_HOST:-$(az afd endpoint show --profile-name "$profile_name" --endpoint-name "$endpoint_name" --resource-group "$RG" --query hostName --output tsv)}"
origin_group_name="${FRONT_DOOR_ORIGIN_GROUP_NAME:-$(az afd origin-group list --profile-name "$profile_name" --resource-group "$RG" --query '[0].name' --output tsv)}"
autoscale_name="${AUTOSCALE_SETTINGS_NAME:-$(az monitor autoscale list --resource-group "$RG" --query "[?starts_with(name, '${APP_NAME}')].name | [0]" --output tsv)}"

printf 'Front Door smoke target: https://%s\n' "$endpoint_host"

home_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "https://${endpoint_host}")"
if [ "$home_status" = '200' ]; then
    printf 'PASS: Front Door endpoint returned HTTP 200\n'
else
    printf 'FAIL: Front Door endpoint returned HTTP %s\n' "$home_status" >&2
    failure_count=$((failure_count + 1))
fi

endpoint_state="$(az afd endpoint show --profile-name "$profile_name" --endpoint-name "$endpoint_name" --resource-group "$RG" --query enabledState --output tsv)"
if [ "$endpoint_state" = 'Enabled' ]; then
    printf 'PASS: Front Door endpoint is enabled\n'
else
    printf 'FAIL: Front Door endpoint enabledState is %s\n' "$endpoint_state" >&2
    failure_count=$((failure_count + 1))
fi

security_policy_count="$(az afd security-policy list --profile-name "$profile_name" --resource-group "$RG" --query 'length([])' --output tsv)"
if [ "$security_policy_count" -ge 1 ]; then
    printf 'PASS: Front Door WAF security policy is attached\n'
else
    printf 'FAIL: No Front Door security policy is attached\n' >&2
    failure_count=$((failure_count + 1))
fi

autoscale_maximum="$(az monitor autoscale show --name "$autoscale_name" --resource-group "$RG" --query 'profiles[0].capacity.maximum' --output tsv)"
if [ "$autoscale_maximum" = '2' ]; then
    printf 'PASS: Autoscale maximum capacity is 2\n'
else
    printf 'FAIL: Autoscale maximum capacity is %s\n' "$autoscale_maximum" >&2
    failure_count=$((failure_count + 1))
fi

probe_path="$(az afd origin-group show --profile-name "$profile_name" --origin-group-name "$origin_group_name" --resource-group "$RG" --query 'healthProbeSettings.probePath' --output tsv)"
if [ "$probe_path" = '/healthz' ]; then
    printf 'PASS: Front Door origin group health probe path is /healthz\n'
else
    printf 'FAIL: Front Door origin group health probe path is %s\n' "$probe_path" >&2
    failure_count=$((failure_count + 1))
fi

if [ "$failure_count" -gt 0 ]; then
    printf 'FAIL: frontdoor-smoke.sh finished with %s failed checks\n' "$failure_count" >&2
    exit 1
fi

printf 'PASS: frontdoor-smoke.sh finished successfully\n'
