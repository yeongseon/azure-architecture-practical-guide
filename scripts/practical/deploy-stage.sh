#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
COMMON_SCRIPT="${SCRIPT_DIR}/common.sh"
STAGE_ENV_FILE="${1:?Usage: bash scripts/practical/deploy-stage.sh <stage-env-file>}"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STORE_FRONT_PROJECT="${PROJECT_ROOT}/src/practical-storefront/src/Practical.Storefront.Web/Practical.Storefront.Web.csproj"

# shellcheck source=/dev/null
source "$COMMON_SCRIPT"
# shellcheck source=/dev/null
source "$STAGE_ENV_FILE"

validate_az_cli

publish_storefront_package() {
    if ! command -v dotnet >/dev/null 2>&1; then
        printf 'ERROR: dotnet SDK is required to publish the Practical Storefront app.\n' >&2
        exit 1
    fi

    local work_dir
    local publish_dir
    local package_path
    work_dir="$(mktemp -d)"
    publish_dir="${work_dir}/publish"
    package_path="${work_dir}/practical-storefront.zip"

    printf 'Publishing Practical Storefront app\n' >&2
    dotnet publish "$STORE_FRONT_PROJECT" --configuration Release --output "$publish_dir" >/dev/null

    python3 - "$publish_dir" "$package_path" <<'PY'
import sys
import zipfile
from pathlib import Path

publish_dir = Path(sys.argv[1])
package_path = Path(sys.argv[2])

with zipfile.ZipFile(package_path, "w", zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(publish_dir.rglob("*")):
        if path.is_file():
            archive.write(path, path.relative_to(publish_dir))
PY

    printf '%s\n' "$package_path"
}

deploy_storefront_package() {
    local package_path="$1"
    local web_app_names

    mapfile -t web_app_names < <(
        az webapp list \
            --resource-group "$RG" \
            --query "[].name" \
            --output tsv
    )

    if [ "${#web_app_names[@]}" -eq 0 ]; then
        printf 'ERROR: No web apps found in resource group %s after deployment.\n' "$RG" >&2
        exit 1
    fi

    local web_app_name
    for web_app_name in "${web_app_names[@]}"; do
        printf 'Deploying Practical Storefront package to %s\n' "$web_app_name"
        az webapp deployment source config-zip \
            --resource-group "$RG" \
            --name "$web_app_name" \
            --src "$package_path" >/dev/null

        printf 'Restarting %s after package deployment\n' "$web_app_name"
        az webapp restart \
            --resource-group "$RG" \
            --name "$web_app_name" >/dev/null
    done
}

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

PACKAGE_PATH="$(publish_storefront_package)"
deploy_storefront_package "$PACKAGE_PATH"

printf 'Deployment finished for %s\n' "$STAGE"
