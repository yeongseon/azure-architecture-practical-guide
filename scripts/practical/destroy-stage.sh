#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
COMMON_SCRIPT="${SCRIPT_DIR}/common.sh"
STAGE_ENV_FILE="${1:?Usage: bash scripts/practical/destroy-stage.sh <stage-env-file>}"

# shellcheck source=/dev/null
source "$COMMON_SCRIPT"
# shellcheck source=/dev/null
source "$STAGE_ENV_FILE"

validate_az_cli

RG="$(generate_rg_name)"

printf 'Deleting resource group %s\n' "$RG"
az group delete --name "$RG" --yes --no-wait

for attempt in $(seq 1 60); do
    if az group show --name "$RG" >/dev/null 2>&1; then
        printf 'Deletion still in progress for %s (attempt %s/60)\n' "$RG" "$attempt"
        sleep 15
        continue
    fi

    printf 'Verified resource group deletion for %s\n' "$RG"
    exit 0
done

printf 'ERROR: Resource group %s still exists or deletion is not yet visible.\n' "$RG" >&2
exit 1
