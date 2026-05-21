#!/usr/bin/env bash

set -euo pipefail

: "${RG:?RG must be exported before running private-connectivity-smoke.sh}"

failure_count=0

private_endpoint_name="$(az resource list --resource-group "$RG" --resource-type "Microsoft.Network/privateEndpoints" --query "[0].name" --output tsv)"
sql_server_name="$(az resource list --resource-group "$RG" --resource-type "Microsoft.Sql/servers" --query "[0].name" --output tsv)"
front_door_host_name="$(az resource list --resource-group "$RG" --resource-type "Microsoft.Cdn/profiles/afdEndpoints" --query "[0].properties.hostName" --output tsv)"

if [ -z "$private_endpoint_name" ]; then
    printf 'FAIL: No SQL private endpoint was found in resource group %s\n' "$RG" >&2
    failure_count=$((failure_count + 1))
else
    private_endpoint_status="$(az network private-endpoint show --name "$private_endpoint_name" --resource-group "$RG" --query "privateLinkServiceConnections[0].privateLinkServiceConnectionState.status" --output tsv)"
    if [ "$private_endpoint_status" = 'Approved' ]; then
        printf 'PASS: Private endpoint %s is Approved\n' "$private_endpoint_name"
    else
        printf 'FAIL: Private endpoint %s status is %s\n' "$private_endpoint_name" "$private_endpoint_status" >&2
        failure_count=$((failure_count + 1))
    fi
fi

if [ -z "$sql_server_name" ]; then
    printf 'FAIL: No Azure SQL logical server was found in resource group %s\n' "$RG" >&2
    failure_count=$((failure_count + 1))
else
    sql_public_network_access="$(az sql server show --name "$sql_server_name" --resource-group "$RG" --query publicNetworkAccess --output tsv)"
    if [ "$sql_public_network_access" = 'Disabled' ]; then
        printf 'PASS: Azure SQL logical server %s has public network access disabled\n' "$sql_server_name"
    else
        printf 'FAIL: Azure SQL logical server %s has public network access %s\n' "$sql_server_name" "$sql_public_network_access" >&2
        failure_count=$((failure_count + 1))
    fi
fi

if [ -z "$front_door_host_name" ]; then
    printf 'FAIL: No Azure Front Door endpoint was found in resource group %s\n' "$RG" >&2
    failure_count=$((failure_count + 1))
else
    front_door_status_code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "https://${front_door_host_name}")"
    if [ "$front_door_status_code" = '200' ]; then
        printf 'PASS: Azure Front Door endpoint %s returned HTTP 200\n' "$front_door_host_name"
    else
        printf 'FAIL: Azure Front Door endpoint %s returned HTTP %s\n' "$front_door_host_name" "$front_door_status_code" >&2
        failure_count=$((failure_count + 1))
    fi
fi

if [ "$failure_count" -gt 0 ]; then
    exit 1
fi
