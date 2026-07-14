#!/usr/bin/env bash
set -euo pipefail

: "${RG:?RG must be set by verify-stage.sh}"

if ! command -v az >/dev/null 2>&1; then
  echo "[warn] az CLI not available; skipping failover smoke test." >&2
  exit 0
fi

fail=0

app_count="$(az webapp list --resource-group "$RG" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
if [[ "${app_count:-0}" -ge 2 ]]; then
  echo "[ ok ] ${app_count} web apps found (expected primary + secondary)."
else
  echo "[fail] found ${app_count:-0} web app(s); expected at least 2 (primary + secondary)." >&2
  fail=$((fail + 1))
fi

distinct_regions="$(az webapp list --resource-group "$RG" --query "[].location" --output tsv 2>/dev/null | sort -u | wc -l | tr -d ' ')"
if [[ "${distinct_regions:-0}" -ge 2 ]]; then
  echo "[ ok ] web apps span ${distinct_regions} regions."
else
  echo "[fail] web apps span ${distinct_regions:-0} region(s); expected 2 for active-passive." >&2
  fail=$((fail + 1))
fi

sql_count="$(az sql server list --resource-group "$RG" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
if [[ "${sql_count:-0}" -ge 2 ]]; then
  echo "[ ok ] ${sql_count} SQL logical servers found (expected primary + secondary)."
else
  echo "[fail] found ${sql_count:-0} SQL logical server(s); expected at least 2." >&2
  fail=$((fail + 1))
fi

primary_server=""
fog_name=""
fog_role=""
# A failover group is visible from both member servers, but only the current
# read-write member reports replicationRole=Primary. Scan all servers and keep
# the Primary so verification does not depend on 'az sql server list' ordering.
for server in $(az sql server list --resource-group "$RG" --query "[].name" --output tsv 2>/dev/null || true); do
  candidate="$(az sql failover-group list --server "$server" --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
  if [[ -z "$candidate" || "$candidate" == "null" ]]; then
    continue
  fi
  candidate_role="$(az sql failover-group show --name "$candidate" --server "$server" --resource-group "$RG" --query "replicationRole" --output tsv 2>/dev/null || true)"
  if [[ -z "$fog_name" ]]; then
    fog_name="$candidate"
    fog_role="$candidate_role"
    primary_server="$server"
  fi
  if [[ "$candidate_role" == "Primary" ]]; then
    fog_name="$candidate"
    fog_role="$candidate_role"
    primary_server="$server"
    break
  fi
done

if [[ -n "$fog_name" ]]; then
  echo "[ ok ] SQL failover group '${fog_name}' found on server '${primary_server}'."
  if [[ "$fog_role" == "Primary" ]]; then
    echo "[ ok ] failover group read-write role is Primary on '${primary_server}'."
  else
    echo "[fail] failover group role on '${primary_server}' is '${fog_role:-unknown}' (expected 'Primary')." >&2
    fail=$((fail + 1))
  fi

  db_count="$(az sql failover-group show --name "$fog_name" --server "$primary_server" --resource-group "$RG" --query "length(databases)" --output tsv 2>/dev/null || echo 0)"
  if [[ "${db_count:-0}" -ge 1 ]]; then
    echo "[ ok ] failover group protects ${db_count} database(s)."
  else
    echo "[fail] failover group protects no databases." >&2
    fail=$((fail + 1))
  fi
else
  echo "[fail] no SQL failover group found on any server in resource group '${RG}'." >&2
  fail=$((fail + 1))
fi

profile="$(az afd profile list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -n "$profile" && "$profile" != "null" ]]; then
  og_name="$(az afd origin-group list --profile-name "$profile" --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
  origin_count="$(az afd origin list --profile-name "$profile" --resource-group "$RG" --origin-group-name "$og_name" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
  if [[ "${origin_count:-0}" -ge 2 ]]; then
    echo "[ ok ] Front Door origin group '${og_name}' has ${origin_count} origins."
  else
    echo "[fail] Front Door origin group '${og_name:-none}' has ${origin_count:-0} origin(s); expected 2 for failover." >&2
    fail=$((fail + 1))
  fi

  priorities="$(az afd origin list --profile-name "$profile" --resource-group "$RG" --origin-group-name "$og_name" --query "[].priority" --output tsv 2>/dev/null | sort -u | tr '\n' ' ' || true)"
  if [[ " $priorities" == *" 1 "* && " $priorities" == *" 2 "* ]]; then
    echo "[ ok ] origins use distinct priorities (${priorities%% }) for active-passive routing."
  else
    echo "[fail] origins do not use priority 1 and priority 2 (found: ${priorities:-none})." >&2
    fail=$((fail + 1))
  fi
else
  echo "[fail] no Front Door profile found in resource group '${RG}'." >&2
  fail=$((fail + 1))
fi

exit "$fail"
