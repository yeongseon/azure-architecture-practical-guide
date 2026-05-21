#!/usr/bin/env bash

set -euo pipefail

: "${WEB_APP_NAME:?WEB_APP_NAME must be exported before running http-smoke.sh}"

WEB_APP_URL="https://${WEB_APP_NAME}.azurewebsites.net"
failure_count=0
max_attempts=24
sleep_seconds=10

printf 'HTTP smoke target: %s\n' "$WEB_APP_URL"

for attempt in $(seq 1 "$max_attempts"); do
    home_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$WEB_APP_URL/" || true)"
    health_response="$(curl --silent --show-error "$WEB_APP_URL/healthz" || true)"
    ops_info_response="$(curl --silent --show-error "$WEB_APP_URL/ops/info" || true)"

    if [ "$home_status" = '200' ] && [[ "$health_response" == *'Healthy'* ]] && [[ "$ops_info_response" == *'"version"'* ]]; then
        printf 'PASS: GET / returned HTTP 200\n'
        printf 'PASS: GET /healthz reported Healthy\n'
        printf 'PASS: GET /ops/info returned version metadata\n'
        exit 0
    fi

    printf 'Waiting for web app readiness. Attempt %s/%s, home=%s, health=%s\n' \
        "$attempt" "$max_attempts" "$home_status" "$health_response"
    sleep "$sleep_seconds"
done

printf 'FAIL: Web app did not become ready after %s attempts\n' "$max_attempts" >&2
failure_count=$((failure_count + 1))

if [ "$failure_count" -gt 0 ]; then
    exit 1
fi
