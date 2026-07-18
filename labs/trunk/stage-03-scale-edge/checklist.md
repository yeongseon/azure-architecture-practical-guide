# Stage 3 — Scale / Edge Deployment Checklist

Use this checklist to deploy, verify, and tear down the Stage 3 scale-and-edge architecture.

## Prerequisites

- [ ] Azure CLI installed and logged in (`az login`).
- [ ] Subscription selected (`az account set --subscription <subscription-id>`).
- [ ] Permission to create resource groups, resources, and **role assignments**.
- [ ] Strong SQL admin password exported: `export SQL_ADMIN_PASSWORD='...'`.
- [ ] SQL Entra admin identifiers exported: `export SQL_ENTRA_ADMIN_LOGIN='...'` and `export SQL_ENTRA_ADMIN_OBJECT_ID='...'`.
- [ ] Alert notification email exported: `export ALERT_EMAIL_ADDRESS='...'`.

## Deploy

- [ ] Run `scripts/practical/deploy-stage.sh stage-03`.
- [ ] Deployment completes without errors (35–50 minutes).
- [ ] Note the printed **Front Door endpoint URL**, **web app URL**, and **autoscale name**.

## Verify

- [ ] `curl https://<frontDoorEndpoint>/` eventually returns `200` (allow several minutes for global propagation).
- [ ] `az afd endpoint show` reports `enabledState` of `Enabled`.
- [ ] `az afd security-policy list` returns at least one WAF security policy.
- [ ] `az afd origin-group list` reports `healthProbeSettings.probePath` of `/healthz`.
- [ ] `az monitor autoscale list` reports `profiles[0].capacity.maximum` of `2`.
- [ ] `GET /healthz` on the origin returns `{"status":"Healthy"}`.
- [ ] `scripts/practical/verify-stage.sh stage-03` exits `0`.

## Clean up

- [ ] Run `scripts/practical/destroy-stage.sh stage-03`.
- [ ] `az group show --resource-group rg-practical-storefront-stage03` eventually returns "not found".

## Related

- [Stage 3 — Scale / Edge walkthrough](../../../docs/practical-journey/stage-03-scale-edge.md)
- [Expected results](expected-results.md)
- [Sample requests](sample-requests.http)
