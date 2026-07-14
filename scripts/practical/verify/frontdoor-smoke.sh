#!/usr/bin/env bash
set -euo pipefail

: "${RG:?RG must be set by verify-stage.sh}"

if ! command -v az >/dev/null 2>&1; then
  echo "[warn] az CLI not available; skipping Front Door smoke test." >&2
  exit 0
fi

fail=0

profile="$(az afd profile list --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
if [[ -z "$profile" || "$profile" == "null" ]]; then
  echo "[fail] no Front Door profile found in resource group '${RG}'." >&2
  exit 1
fi
echo "[ ok ] Front Door profile '${profile}' found."

endpoint="$(az afd endpoint list --profile-name "$profile" --resource-group "$RG" --query "[0].name" --output tsv 2>/dev/null || true)"
endpoint_host="$(az afd endpoint list --profile-name "$profile" --resource-group "$RG" --query "[0].hostName" --output tsv 2>/dev/null || true)"
endpoint_state="$(az afd endpoint list --profile-name "$profile" --resource-group "$RG" --query "[0].enabledState" --output tsv 2>/dev/null || true)"

if [[ "$endpoint_state" == "Enabled" ]]; then
  echo "[ ok ] endpoint '${endpoint}' is Enabled."
else
  echo "[fail] endpoint '${endpoint:-none}' is not Enabled (state: ${endpoint_state:-unknown})." >&2
  fail=$((fail + 1))
fi

if [[ -n "$endpoint_host" ]]; then
  code="$(curl -s -o /dev/null -w '%{http_code}' "https://${endpoint_host}/" 2>/dev/null || echo 000)"
  if [[ "$code" == "200" ]]; then
    echo "[ ok ] GET https://${endpoint_host}/ -> 200."
  else
    echo "[warn] GET https://${endpoint_host}/ -> ${code}. Front Door endpoints propagate globally over several minutes; retry after propagation and the first successful origin health probe." >&2
  fi
fi

policy_count="$(az afd security-policy list --profile-name "$profile" --resource-group "$RG" --query "length(@)" --output tsv 2>/dev/null || echo 0)"
if [[ "${policy_count:-0}" -ge 1 ]]; then
  echo "[ ok ] ${policy_count} WAF security policy(ies) associated with the endpoint."
else
  echo "[fail] no WAF security policy associated with the Front Door endpoint." >&2
  fail=$((fail + 1))
fi

probe_path="$(az afd origin-group list --profile-name "$profile" --resource-group "$RG" --query "[0].healthProbeSettings.probePath" --output tsv 2>/dev/null || true)"
if [[ "$probe_path" == "/healthz" ]]; then
  echo "[ ok ] origin group health probe path is '/healthz'."
else
  echo "[fail] origin group health probe path is '${probe_path:-none}' (expected '/healthz')." >&2
  fail=$((fail + 1))
fi

autoscale_max="$(az monitor autoscale list --resource-group "$RG" --query "[0].profiles[0].capacity.maximum" --output tsv 2>/dev/null || true)"
if [[ "$autoscale_max" == "2" ]]; then
  echo "[ ok ] autoscale maximum capacity is 2."
else
  echo "[fail] autoscale maximum capacity is '${autoscale_max:-none}' (expected '2')." >&2
  fail=$((fail + 1))
fi

exit "$fail"
