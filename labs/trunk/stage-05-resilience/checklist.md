# Stage 5 — Resilience Deployment Checklist

Use this checklist to deploy, verify, run a failover drill on, and tear down the Stage 5 active-passive resilience architecture.

## Prerequisites

- [ ] Azure CLI installed and logged in (`az login`).
- [ ] Subscription selected (`az account set --subscription <id>`).
- [ ] Permission to create resource groups in two regions, SQL failover groups, and **role assignments**.
- [ ] Secondary-region capacity for App Service **S1** and Azure SQL (default secondary: `japaneast`).
- [ ] Strong SQL admin password exported: `export SQL_ADMIN_PASSWORD='...'` (used on both servers).
- [ ] SQL Entra admin identifiers exported: `export SQL_ENTRA_ADMIN_LOGIN='...'` and `export SQL_ENTRA_ADMIN_OBJECT_ID='...'`.
- [ ] Alert notification email exported: `export ALERT_EMAIL_ADDRESS='...'`.

## Deploy

- [ ] Run `scripts/practical/deploy-stage.sh stage-05`.
- [ ] Deployment completes without errors (50–75 minutes).
- [ ] Note the printed **Front Door endpoint URL**, **primary web app name**, **secondary web app name**, **primary SQL server**, **secondary SQL server**, and **failover group name**.

## Verify

- [ ] `az webapp list --resource-group rg-practical-storefront-stage05 --query "length(@)"` returns `2` or more.
- [ ] The two web apps report two distinct `location` values (primary and secondary regions).
- [ ] `az sql server list` returns two servers.
- [ ] `az sql failover-group show --server <primarySqlServer> --query replicationRole` reports `Primary`.
- [ ] `az afd origin list` on the origin group returns two origins with priorities `1` and `2`.
- [ ] `curl https://<frontDoorEndpoint>/` eventually returns `200` (allow several minutes for global propagation).
- [ ] `curl https://<frontDoorEndpoint>/ops/info` reports `"region": "primary"`.
- [ ] `scripts/practical/verify-stage.sh stage-05` exits `0`.

## Failover drill

- [ ] `az webapp stop --name <primaryWebApp> --resource-group rg-practical-storefront-stage05` exits `0`.
- [ ] After ~60 seconds, `curl https://<frontDoorEndpoint>/ops/info` reports `"region": "secondary"` (app-tier failover).
- [ ] `az sql failover-group set-primary --name <failoverGroup> --server <secondarySqlServer> --resource-group rg-practical-storefront-stage05` exits `0`.
- [ ] `az sql failover-group show --name <failoverGroup> --server <secondarySqlServer> --query replicationRole` reports `Primary` (data-tier failover).

## Fail back

- [ ] `az webapp start --name <primaryWebApp> --resource-group rg-practical-storefront-stage05` exits `0`.
- [ ] `az sql failover-group set-primary --name <failoverGroup> --server <primarySqlServer> --resource-group rg-practical-storefront-stage05` exits `0`.
- [ ] `curl https://<frontDoorEndpoint>/ops/info` reports `"region": "primary"` again.

## Clean up

- [ ] Run `scripts/practical/destroy-stage.sh stage-05`.
- [ ] `az group show --resource-group rg-practical-storefront-stage05` eventually returns "not found".

## Related

- [Stage 5 — Resilience walkthrough](../../../docs/practical-journey/stage-05-resilience.md)
- [Expected results](expected-results.md)
- [Sample requests](sample-requests.http)
