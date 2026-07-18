# Stage 3 — Scale / Edge Infrastructure

This directory deploys the Stage 3 architecture for the **Practical Storefront** journey. It builds on the [Stage 2](../stage-02-production-baseline/) production baseline and adds the two things an app needs once traffic grows and internet exposure becomes a concern: **managed edge protection** and **autoscaling**.

## What gets deployed

Stage 3 is self-contained: it deploys the full Stage 2 stack plus the edge and scale resources below, so it can stand up in a fresh resource group on its own.

| Resource | Module | SKU / Tier | Notes |
|---|---|---|---|
| Log Analytics workspace | `foundation/log-analytics-workspace.bicep` | PerGB2018, 30-day retention | Telemetry backend |
| Application Insights | `foundation/application-insights.bicep` | Workspace-based | Wired to app and slot |
| App Service plan | `web/app-service-plan.bicep` | Linux **S1** (Standard) | Autoscale-capable host |
| Web App | `web/web-app.bicep` | `DOTNETCORE\|8.0` | System-assigned managed identity |
| Staging slot | `web/web-app-slot.bicep` | Shares the S1 plan | Safe pre-production releases |
| Key Vault | `foundation/key-vault.bicep` | Standard, RBAC | Custody of the SQL connection string |
| SQL logical server | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | `publicNetworkAccess: Enabled` |
| SQL Database | `data/sql-database.bicep` | **Basic** | 2 GB max |
| SQL Entra admin | inline (`administrators`) | ActiveDirectory | Foundation for passwordless SQL |
| Action Group | `foundation/action-group.bicep` | Email receiver | Alert notification target |
| Metric alerts | `foundation/metric-alerts.bicep` | Http5xx, HttpResponseTime | Tied to the action group |
| Key Vault role assignments | `foundation/key-vault-role-assignment.bicep` | Key Vault Secrets User | Granted to app and slot identities, scoped to the vault |
| **Autoscale setting** | `foundation/autoscale-settings.bicep` | CPU-based, min 1 / max 2 | Scales the S1 plan out and back in |
| **Front Door profile** | `web/front-door-standard.bicep` | Standard_AzureFrontDoor | Global edge entry point |
| **WAF policy** | `web/front-door-standard.bicep` | Prevention mode, DRS 2.1 | Blocks common web attacks at the edge |
| **Origin group + origin + route** | inline (`Microsoft.Cdn`) | Health probe `/healthz` | Routes edge traffic to the web app |

Estimated cost: **~$0.20–$0.30/hour**. Deploy time: **35–50 minutes**.

## Design intent

- **Edge protection outside the app** — Front Door terminates user traffic at the global edge, and a WAF policy in Prevention mode blocks common attacks (the Microsoft Default Rule Set) before requests ever reach application code.
- **Autoscale on a signal** — the App Service plan scales out when average CPU exceeds 70% and scales back in below 30%, between 1 and 2 instances. Scale-out is only safe because the app is stateless.
- **Health-probed routing** — the Front Door origin group probes `/healthz` so unhealthy instances are taken out of rotation automatically.
- **WAF before custom code** — request filtering happens at the edge, keeping malicious traffic away from the origin.

> Front Door reaches the web app over its public hostname at this stage. Locking the origin down so it only accepts traffic from this Front Door instance (via the `X-Azure-FDID` header and the `AzureFrontDoor.Backend` service tag), and moving the origin behind a private endpoint, happen in a later stage. The public SQL and Key Vault endpoints are likewise tightened later.

## Deploy

Export the required secrets and identifiers (never commit them), then deploy with the parameter file:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
export SQL_ENTRA_ADMIN_LOGIN='<entra-user-or-group-display-name>'
export SQL_ENTRA_ADMIN_OBJECT_ID='<entra-object-id>'
export ALERT_EMAIL_ADDRESS='<ops-notification-email>'
export RG='rg-practical-storefront-stage03'
export LOCATION='koreacentral'

az group create --resource-group "$RG" --location "$LOCATION"

az deployment group create \
  --resource-group "$RG" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Prefer the generic driver scripts under `scripts/practical/` for a repeatable deploy → verify → destroy flow:

```bash
scripts/practical/deploy-stage.sh stage-03
scripts/practical/verify-stage.sh stage-03
scripts/practical/destroy-stage.sh stage-03
```

## Verification note

Front Door endpoints propagate globally after deployment, which can take several minutes. On a fresh deploy, the endpoint may return `503` or connection errors until propagation completes and the origin health probe first succeeds. The `frontdoor-smoke.sh` verification treats a non-`200` edge response as a **warning**, not a failure, and hard-fails only the control-plane checks (endpoint enabled, WAF policy present, autoscale maximum, origin health-probe path).

## Outputs

| Output | Purpose |
|---|---|
| `webAppName` | Name of the web app |
| `webAppUrl` | Direct origin URL (bypasses Front Door) |
| `frontDoorEndpointUrl` | Public Front Door URL for user traffic |
| `frontDoorProfileName` | Front Door profile name |
| `frontDoorEndpointName` | Front Door endpoint name |
| `originGroupName` | Origin group with the `/healthz` probe |
| `autoscaleName` | Autoscale setting name |
| `stagingSlotName` | Name of the staging slot |
| `keyVaultName` | Vault holding `SqlConnectionString` |
| `appInsightsName` | For metric queries during verification |
| `sqlServerFqdn` | For SQL connectivity smoke tests |
| `sqlDatabaseName` | Target database name |
| `actionGroupName` | Alert notification group |

## Clean up

```bash
az group delete --name "$RG" --yes --no-wait
```

## See Also

- [Stage 3 — Scale / Edge walkthrough](../../../../docs/practical-journey/stage-03-scale-edge.md)
- [Stage 2 — Production Baseline infrastructure](../stage-02-production-baseline/)
- [Foundation Bicep modules](../../modules/)
