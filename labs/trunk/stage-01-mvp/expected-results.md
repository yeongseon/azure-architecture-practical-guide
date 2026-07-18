# Stage 1 — MVP Expected Results

This document records what a successful Stage 1 deployment and verification looks like. Use it to confirm your run matches the expected baseline.

## HTTP smoke test

| Request | Expected status | Expected body |
|---|---|---|
| `GET /` | `200` | HTML catalog page listing seeded products |
| `GET /healthz` | `200` | `{"status":"Healthy"}` |
| `GET /ops/info` | `200` | JSON with `version` and `region` fields |
| `GET /ops/version` | `200` | JSON with a `version` field |
| `GET /Home/Orders` | `200` | HTML page listing recent orders |
| `POST /Home/Create` | `302` | Redirect to the orders page on success |

Example `GET /ops/info` response:

```json
{
  "version": "1.0.0",
  "region": "koreacentral"
}
```

Example `GET /healthz` response:

```json
{
  "status": "Healthy"
}
```

## SQL connectivity

- TCP `1433` on the SQL logical server FQDN is reachable from Azure services.
- The `sqldb-storefront` database exists and contains the `Products` and `Orders` tables.

## Telemetry

After sending a handful of requests, Application Insights reports request telemetry:

```bash
az monitor app-insights metrics show \
  --app <appInsightsName> \
  --resource-group rg-practical-storefront-stage01 \
  --metric requests/count \
  --interval PT5M
```

Expected: the `value` field is greater than `0`.

## Teardown

```bash
az group delete --name rg-practical-storefront-stage01 --yes --no-wait
```

Expected: exit code `0`. Within a few minutes `az group show` for the resource group returns "not found".

## Related

- [Deployment checklist](checklist.md)
- [Sample requests](sample-requests.http)
- [Stage 1 — MVP walkthrough](../../../docs/practical-journey/stage-01-mvp.md)
