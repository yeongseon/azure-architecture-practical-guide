#!/usr/bin/env bash

set -euo pipefail

: "${RG:?RG must be exported before running sql-smoke.sh}"
: "${SQL_SERVER_NAME:?SQL_SERVER_NAME must be exported before running sql-smoke.sh}"
: "${SQL_DATABASE_NAME:?SQL_DATABASE_NAME must be exported before running sql-smoke.sh}"

failure_count=0

if az sql server show --name "$SQL_SERVER_NAME" --resource-group "$RG" >/dev/null 2>&1; then
    printf 'PASS: Azure SQL logical server %s exists\n' "$SQL_SERVER_NAME"
else
    printf 'FAIL: Azure SQL logical server %s was not found\n' "$SQL_SERVER_NAME" >&2
    failure_count=$((failure_count + 1))
fi

if az sql db show --name "$SQL_DATABASE_NAME" --server "$SQL_SERVER_NAME" --resource-group "$RG" >/dev/null 2>&1; then
    printf 'PASS: Azure SQL database %s exists\n' "$SQL_DATABASE_NAME"
else
    printf 'FAIL: Azure SQL database %s was not found\n' "$SQL_DATABASE_NAME" >&2
    failure_count=$((failure_count + 1))
fi

if [ "$failure_count" -gt 0 ]; then
    exit 1
fi
