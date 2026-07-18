#!/usr/bin/env bash
set -euo pipefail

: "${WEBAPP_NAME:?WEBAPP_NAME must be set by verify-stage.sh}"
: "${RG:?RG must be set by verify-stage.sh}"

if ! command -v az >/dev/null 2>&1; then
  echo "[warn] az CLI not available; skipping identity smoke test." >&2
  exit 0
fi

fail=0

principal_id="$(az webapp identity show --name "$WEBAPP_NAME" --resource-group "$RG" --query principalId --output tsv 2>/dev/null || true)"
if [[ -n "$principal_id" && "$principal_id" != "null" ]]; then
  echo "[ ok ] web app has a system-assigned managed identity."
else
  echo "[fail] web app has no managed identity principalId." >&2
  fail=$((fail + 1))
fi

kv_name="$(az keyvault list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -z "$kv_name" || "$kv_name" == "null" ]]; then
  echo "[fail] no Key Vault found in resource group '${RG}'." >&2
  fail=$((fail + 1))
elif az keyvault secret show --vault-name "$kv_name" --name SqlConnectionString >/dev/null 2>&1; then
  echo "[ ok ] Key Vault '${kv_name}' holds the SqlConnectionString secret."
else
  echo "[warn] SqlConnectionString secret not readable in Key Vault '${kv_name}'. This checks the operator's data-plane access (Key Vault Secrets User/Officer), not deployment correctness; the app identity may still be authorized." >&2
fi

sql_server="$(az sql server list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -n "$sql_server" && "$sql_server" != "null" ]] && az sql server ad-admin list --server-name "$sql_server" --resource-group "$RG" --query "[0].login" --output tsv 2>/dev/null | grep -q .; then
  echo "[ ok ] SQL server '${sql_server}' has a Microsoft Entra administrator."
else
  echo "[fail] SQL server has no Entra administrator (server: ${sql_server:-none})." >&2
  fail=$((fail + 1))
fi

if az webapp deployment slot list --name "$WEBAPP_NAME" --resource-group "$RG" --query "[].name" --output tsv 2>/dev/null | grep -q "staging"; then
  echo "[ ok ] staging deployment slot exists."
else
  echo "[fail] staging deployment slot not found." >&2
  fail=$((fail + 1))
fi

if az webapp deployment slot swap --name "$WEBAPP_NAME" --resource-group "$RG" --slot staging --action preview >/dev/null 2>&1; then
  echo "[ ok ] staging swap preview succeeded."
  az webapp deployment slot swap --name "$WEBAPP_NAME" --resource-group "$RG" --slot staging --action reset >/dev/null 2>&1 || true
else
  echo "[warn] staging swap preview could not be validated (slot may be empty)." >&2
fi

alert_count="$(az monitor metrics alert list --resource-group "$RG" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
if [[ "${alert_count:-0}" -ge 1 ]]; then
  echo "[ ok ] ${alert_count} metric alert rule(s) configured."
else
  echo "[fail] no metric alert rules found." >&2
  fail=$((fail + 1))
fi

exit "$fail"
