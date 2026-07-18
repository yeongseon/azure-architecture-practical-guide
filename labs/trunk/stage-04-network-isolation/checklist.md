# Stage 4 — Network Isolation Deployment Checklist

Use this checklist to deploy, verify, and tear down the Stage 4 network-isolation architecture.

## Prerequisites

- [ ] Azure CLI installed and logged in (`az login`).
- [ ] Subscription selected (`az account set --subscription <id>`).
- [ ] Permission to create resource groups, virtual networks, private endpoints, and **role assignments**.
- [ ] Strong SQL admin password exported: `export SQL_ADMIN_PASSWORD='...'`.
- [ ] SQL Entra admin identifiers exported: `export SQL_ENTRA_ADMIN_LOGIN='...'` and `export SQL_ENTRA_ADMIN_OBJECT_ID='...'`.
- [ ] Alert notification email exported: `export ALERT_EMAIL_ADDRESS='...'`.

## Deploy

- [ ] Run `scripts/practical/deploy-stage.sh stage-04`.
- [ ] Deployment completes without errors (35–55 minutes).
- [ ] Note the printed **Front Door endpoint URL**, **web app URL**, **VNet name**, and **SQL private endpoint name**.

## Verify

- [ ] `az sql server show --query publicNetworkAccess` reports `Disabled`.
- [ ] `az network private-endpoint show` reports connection status `Approved`.
- [ ] `az network private-dns zone show --name privatelink.database.windows.net` returns the zone.
- [ ] `az network private-dns link vnet list` reports at least one VNet link on the SQL zone.
- [ ] From the App Service SSH/Kudu console, `nslookup <sqlServer>.database.windows.net` resolves to a `10.x.x.x` address.
- [ ] `curl https://<frontDoorEndpoint>/` eventually returns `200` (allow several minutes for global propagation).
- [ ] `GET /healthz` on the origin returns `{"status":"Healthy"}`.
- [ ] `scripts/practical/verify-stage.sh stage-04` exits `0`.

## Clean up

- [ ] Run `scripts/practical/destroy-stage.sh stage-04`.
- [ ] `az group show --resource-group rg-practical-storefront-stage04` eventually returns "not found".

## Related

- [Stage 4 — Network Isolation walkthrough](../../../docs/practical-journey/stage-04-network-isolation.md)
- [Expected results](expected-results.md)
- [Sample requests](sample-requests.http)
