#!/usr/bin/env bash

set -euo pipefail

LOCATION="${LOCATION:-koreacentral}"

generate_rg_name() {
    if [ -n "${RG:-}" ]; then
        printf '%s\n' "$RG"
        return
    fi

    local stage_name="${STAGE:?STAGE must be set before calling generate_rg_name}"
    local region_name="${LOCATION:-koreacentral}"
    printf 'rg-practical-%s-%s\n' "$stage_name" "$region_name"
}

validate_az_cli() {
    if ! command -v az >/dev/null 2>&1; then
        printf 'ERROR: Azure CLI is not installed.\n' >&2
        exit 1
    fi

    if ! az account show >/dev/null 2>&1; then
        printf 'ERROR: Azure CLI is not logged in. Run az login first.\n' >&2
        exit 1
    fi
}

print_cost_warning() {
    local stage_name="${STAGE:-unknown-stage}"
    local cost_range="${1:-Estimated stage cost varies by chosen services.}"

    printf 'Estimated cost for %s: %s\n' "$stage_name" "$cost_range"
    printf 'Reminder: destroy the resource group after verification to minimize Azure spend.\n'
}
