#!/usr/bin/env bash
set -euo pipefail

: "${WEBAPP_URL:?WEBAPP_URL must be set by verify-stage.sh}"

fail=0

check_status() {
  local path="$1" expected="$2"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' "${WEBAPP_URL}${path}")"
  if [[ "$code" == "$expected" ]]; then
    printf '[ ok ] GET %-14s -> %s\n' "$path" "$code"
  else
    printf '[fail] GET %-14s -> %s (expected %s)\n' "$path" "$code" "$expected" >&2
    fail=$((fail + 1))
  fi
}

check_json_field() {
  local path="$1" field="$2"
  local body
  body="$(curl -s "${WEBAPP_URL}${path}")"
  if printf '%s' "$body" | grep -q "\"${field}\""; then
    printf '[ ok ] GET %-14s -> contains "%s"\n' "$path" "$field"
  else
    printf '[fail] GET %-14s -> missing "%s" (body: %s)\n' "$path" "$field" "$body" >&2
    fail=$((fail + 1))
  fi
}

check_status "/" "200"
check_json_field "/healthz" "status"
check_json_field "/ops/info" "version"

exit "$fail"
