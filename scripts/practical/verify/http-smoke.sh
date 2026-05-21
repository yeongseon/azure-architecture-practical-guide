#!/usr/bin/env bash

set -euo pipefail

: "${WEB_APP_NAME:?WEB_APP_NAME must be exported before running http-smoke.sh}"

WEB_APP_URL="https://${WEB_APP_NAME}.azurewebsites.net"
failure_count=0

printf 'HTTP smoke target: %s\n' "$WEB_APP_URL"

home_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$WEB_APP_URL/")"
if [ "$home_status" = '200' ]; then
    printf 'PASS: GET / returned HTTP 200\n'
else
    printf 'FAIL: GET / returned HTTP %s\n' "$home_status" >&2
    failure_count=$((failure_count + 1))
fi

health_response="$(curl --silent --show-error "$WEB_APP_URL/healthz")"
if [[ "$health_response" == *'Healthy'* ]]; then
    printf 'PASS: GET /healthz reported Healthy\n'
else
    printf 'FAIL: GET /healthz did not report Healthy. Response: %s\n' "$health_response" >&2
    failure_count=$((failure_count + 1))
fi

ops_info_response="$(curl --silent --show-error "$WEB_APP_URL/ops/info")"
if [[ "$ops_info_response" == *'"version"'* ]]; then
    printf 'PASS: GET /ops/info returned version metadata\n'
else
    printf 'FAIL: GET /ops/info did not include version metadata. Response: %s\n' "$ops_info_response" >&2
    failure_count=$((failure_count + 1))
fi

if [ "$failure_count" -gt 0 ]; then
    exit 1
fi
