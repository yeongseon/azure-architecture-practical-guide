#!/usr/bin/env bash
set -euo pipefail

: "${RG:?RG must be set by verify-stage.sh}"

if ! command -v az >/dev/null 2>&1; then
  echo "[warn] az CLI not available; skipping private connectivity smoke test." >&2
  exit 0
fi

fail=0

sql_server="$(az sql server list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -z "$sql_server" || "$sql_server" == "null" ]]; then
  echo "[fail] no SQL logical server found in resource group '${RG}'." >&2
  exit 1
fi
echo "[ ok ] SQL logical server '${sql_server}' found."

public_access="$(az sql server show --name "$sql_server" --resource-group "$RG" --query "publicNetworkAccess" --output tsv 2>/dev/null || true)"
if [[ "$public_access" == "Disabled" ]]; then
  echo "[ ok ] SQL public network access is Disabled."
else
  echo "[fail] SQL public network access is '${public_access:-unknown}' (expected 'Disabled')." >&2
  fail=$((fail + 1))
fi

pe_name="$(az network private-endpoint list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -z "$pe_name" || "$pe_name" == "null" ]]; then
  echo "[fail] no private endpoint found in resource group '${RG}'." >&2
  fail=$((fail + 1))
else
  echo "[ ok ] private endpoint '${pe_name}' found."
  pe_status="$(az network private-endpoint show --name "$pe_name" --resource-group "$RG" --query "privateLinkServiceConnections[0].privateLinkServiceConnectionState.status" --output tsv 2>/dev/null || true)"
  if [[ "$pe_status" == "Approved" ]]; then
    echo "[ ok ] private endpoint connection status is Approved."
  else
    echo "[fail] private endpoint connection status is '${pe_status:-unknown}' (expected 'Approved')." >&2
    fail=$((fail + 1))
  fi
fi

dns_zone="$(az network private-dns zone list --resource-group "$RG" --query "[?contains(name, 'database.windows.net')] | [0].name" --output tsv 2>/dev/null || true)"
if [[ -n "$dns_zone" && "$dns_zone" != "null" ]]; then
  echo "[ ok ] private DNS zone '${dns_zone}' present."
  link_count="$(az network private-dns link vnet list --resource-group "$RG" --zone-name "$dns_zone" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
  if [[ "${link_count:-0}" -ge 1 ]]; then
    echo "[ ok ] ${link_count} virtual network link(s) attached to the SQL private DNS zone."
  else
    echo "[fail] SQL private DNS zone has no virtual network links." >&2
    fail=$((fail + 1))
  fi
else
  echo "[fail] no SQL private DNS zone (privatelink.database.windows.net) found." >&2
  fail=$((fail + 1))
fi

exit "$fail"
