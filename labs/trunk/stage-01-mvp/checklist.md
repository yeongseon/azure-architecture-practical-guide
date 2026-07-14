# Stage 1 — MVP Deployment Checklist

Use this checklist to deploy, verify, and tear down the Stage 1 MVP baseline.

## Prerequisites

- [ ] Azure CLI installed and logged in (`az login`).
- [ ] Subscription selected (`az account set --subscription <id>`).
- [ ] Permission to create resource groups and resources.
- [ ] Strong SQL admin password exported: `export SQL_ADMIN_PASSWORD='...'`.

## Deploy

- [ ] Run `scripts/practical/deploy-stage.sh stage-01`.
- [ ] Deployment completes without errors (20–30 minutes).
- [ ] Note the printed **web app URL** and **Application Insights name**.

## Verify

- [ ] `GET /` returns `200`.
- [ ] `GET /healthz` returns `{"status":"Healthy"}`.
- [ ] `GET /ops/info` returns JSON containing a `version` field.
- [ ] `GET /ops/version` returns JSON containing a `version` field.
- [ ] SQL server is reachable on TCP 1433.
- [ ] `az monitor app-insights metrics show --metric requests/count` reports `value > 0` after a few requests.
- [ ] `scripts/practical/verify-stage.sh stage-01` exits `0`.

## Clean up

- [ ] Run `scripts/practical/destroy-stage.sh stage-01`.
- [ ] `az group show --resource-group rg-practical-storefront-stage01` eventually returns "not found".

## Related

- [Stage 1 — MVP walkthrough](../../../docs/practical-journey/stage-01-mvp.md)
- [Expected results](expected-results.md)
- [Sample requests](sample-requests.http)
