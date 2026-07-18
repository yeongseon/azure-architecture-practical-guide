# Stage 2 — Production Baseline Deployment Checklist

Use this checklist to deploy, verify, and tear down the Stage 2 production baseline.

## Prerequisites

- [ ] Azure CLI installed and logged in (`az login`).
- [ ] Subscription selected (`az account set --subscription <id>`).
- [ ] Permission to create resource groups, resources, and **role assignments**.
- [ ] Strong SQL admin password exported: `export SQL_ADMIN_PASSWORD='...'`.
- [ ] SQL Entra admin identifiers exported: `export SQL_ENTRA_ADMIN_LOGIN='...'` and `export SQL_ENTRA_ADMIN_OBJECT_ID='...'`.
- [ ] Alert notification email exported: `export ALERT_EMAIL_ADDRESS='...'`.

## Deploy

- [ ] Run `scripts/practical/deploy-stage.sh stage-02`.
- [ ] Deployment completes without errors (25–40 minutes).
- [ ] Note the printed **web app URL**, **Key Vault name**, and **staging slot name**.

## Verify

- [ ] `GET /` returns `200`.
- [ ] `GET /healthz` returns `{"status":"Healthy"}`.
- [ ] `az webapp identity show` reports a non-empty `principalId`.
- [ ] `az keyvault secret show --name SqlConnectionString` exits `0`.
- [ ] `az sql server ad-admin list` returns an Entra principal.
- [ ] `az webapp deployment slot list` contains `staging`.
- [ ] `az webapp deployment slot swap --action preview` exits `0`.
- [ ] `az monitor metrics alert list` returns at least one alert rule.
- [ ] `scripts/practical/verify-stage.sh stage-02` exits `0`.

## Clean up

- [ ] Run `scripts/practical/destroy-stage.sh stage-02`.
- [ ] `az group show --resource-group rg-practical-storefront-stage02` eventually returns "not found".

## Related

- [Stage 2 — Production Baseline walkthrough](../../../docs/practical-journey/stage-02-production-baseline.md)
- [Expected results](expected-results.md)
- [Sample requests](sample-requests.http)
