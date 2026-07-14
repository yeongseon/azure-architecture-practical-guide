#!/usr/bin/env bash
set -euo pipefail

PRACTICAL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${PRACTICAL_ROOT}/../.." && pwd)"
export PRACTICAL_ROOT REPO_ROOT

log()  { printf '\033[0;34m[practical]\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m[ ok ]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[warn]\033[0m %s\n' "$*"; }
err()  { printf '\033[0;31m[fail]\033[0m %s\n' "$*" >&2; }

die() { err "$*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

load_stage_env() {
  local stage_id="$1"
  local env_file="${PRACTICAL_ROOT}/stages/${stage_id}.env"
  [[ -f "$env_file" ]] || die "Stage env file not found: $env_file"
  # shellcheck disable=SC1090
  source "$env_file"
}

require_azure_login() {
  require_cmd az
  az account show >/dev/null 2>&1 || die "Not logged in to Azure. Run: az login"
}

ensure_resource_group() {
  local rg="$1" location="$2"
  if az group show --resource-group "$rg" >/dev/null 2>&1; then
    log "Resource group '$rg' already exists."
  else
    log "Creating resource group '$rg' in '$location'."
    az group create --resource-group "$rg" --location "$location" --output none
    ok "Resource group '$rg' created."
  fi
}

deployment_output() {
  local rg="$1" deployment="$2" key="$3"
  az deployment group show \
    --resource-group "$rg" \
    --name "$deployment" \
    --query "properties.outputs.${key}.value" \
    --output tsv 2>/dev/null
}
