# Stage 5 — Resilience Infrastructure

This directory deploys the Stage 5 architecture for the **Practical Storefront** journey. It teaches **multi-region active-passive resilience**: a second regional app stack stands ready, an Azure SQL failover group keeps a synchronized replica in the secondary region, and Azure Front Door fails user traffic over automatically when the primary region's app stops answering.

## Stage 4 and Stage 5 teach separate production concerns

Stage 4 made the **data tier private** (Private Endpoint, `publicNetworkAccess: Disabled`, VNet integration). Stage 5 is not built on Stage 4 — it **resets to the Stage 3 public baseline** so the resilience lesson stays focused on one concern at a time. Combining private networking with multi-region failover (private endpoints per region, cross-region DNS, region-aware routing) is a materially harder design that is deferred to the capstone.

| Concern | Stage 4 | Stage 5 | Capstone |
|---|---|---|---|
| Data tier network exposure | Private only (`Disabled`) | **Public** (Stage 3 baseline) | Private, multi-region |
| Regions | Single | **Two (active-passive)** | Two, private |
| SQL topology | One server, one DB, private endpoint | **Two servers, failover group** | Two servers, failover group, private endpoints |
| Front Door origins | One | **Two (priority failover)** | Two, origin lockdown |

If you deployed Stage 4, tear it down before deploying Stage 5; the two stages use the same resource names and are meant to be run independently.

## What gets deployed

Stage 5 is self-contained: it deploys the full Stage 3 public stack plus a second regional stack and the failover fabric below, so it can stand up in a fresh resource group on its own. Both regions live in a **single resource group**; the resource group's own location is metadata only.

| Resource | Module | SKU / Tier | Notes |
|---|---|---|---|
| Log Analytics workspace | `foundation/log-analytics-workspace.bicep` | PerGB2018, 30-day retention | Telemetry backend (primary region) |
| Application Insights | `foundation/application-insights.bicep` | Workspace-based | Wired to both regional apps |
| App Service plan (primary) | `web/app-service-plan.bicep` | Linux **S1** (Standard) | Active region host |
| Web App (primary) | `web/web-app.bicep` | `DOTNETCORE\|8.0`, `APP_REGION=primary` | Active app, Front Door priority 1 origin |
| Staging slot (primary) | `web/web-app-slot.bicep` | Shares the primary S1 plan | Safe pre-production releases |
| App Service plan (secondary) | `web/app-service-plan.bicep` | Linux **S1** (Standard) | Passive region host in `secondaryLocation` |
| Web App (secondary) | `web/web-app.bicep` | `DOTNETCORE\|8.0`, `APP_REGION=secondary` | Passive app, Front Door priority 2 origin |
| Key Vault | `foundation/key-vault.bicep` | Standard, RBAC | Holds the failover-group connection string |
| SQL logical server (primary) | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | Read-write role at deploy time |
| SQL logical server (secondary) | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | Failover partner in `secondaryLocation` |
| SQL Database | `data/sql-database.bicep` | **S0** (Standard) | Geo-replicated by the failover group |
| **SQL Failover Group** | `data/sql-failover-group.bicep` | Automatic, 60-min grace | Read-write listener + geo-replication |
| SQL Entra admins | inline (`administrators`) | ActiveDirectory | Set on both servers |
| Azure-services firewall rule | inline (`firewallRules`) | `0.0.0.0` | Set on both servers |
| Action Group | `foundation/action-group.bicep` | Email receiver | Alert notification target |
| Metric alerts | `foundation/metric-alerts.bicep` | Http5xx, HttpResponseTime | Tied to the primary web app |
| Key Vault role assignments | `foundation/key-vault-role-assignment.bicep` | Key Vault Secrets User | Granted to both apps and the slot identity |
| Autoscale setting | `foundation/autoscale-settings.bicep` | CPU-based, min 1 / max 2 | Scales the primary S1 plan |
| Front Door profile + WAF | `web/front-door-standard.bicep` | Standard_AzureFrontDoor | Global edge, Prevention mode |
| Origin group + two origins + route | inline (`Microsoft.Cdn`) | Health probe `/healthz` | Priority 1 primary, priority 2 secondary |

Estimated cost: **~$0.45–$0.80/hour**. Deploy time: **50–75 minutes**.

## Design intent

- **Active-passive before active-active** — one region serves all traffic; the second is a warm standby. This is the simplest topology that survives a regional outage, and it avoids the multi-writer data problems that active-active introduces. Front Door's priority-based routing sends every request to the priority 1 origin and only shifts to priority 2 when the primary fails its health probe.
- **One connection string, bound to the failover listener** — both regional apps read the identical `ConnectionStrings__StorefrontDb` secret, which targets the failover group's read-write **listener** (`<fog-name>.database.windows.net`), never a specific server. The listener always points at whichever server currently holds the read-write role, so a data-tier failover requires no app configuration change.
- **App-tier and data-tier failover are independent** — stopping the primary web app fails **user traffic** over via Front Door, but the database read-write role stays in the primary region until you explicitly run `az sql failover-group set-primary`. A real regional outage triggers both; a drill lets you exercise them one at a time.
- **Explicit RTO/RPO, tested not assumed** — the failover group uses automatic failover with a 60-minute data-loss grace period. The lab guide walks a full failover drill so the recovery path is proven, not just documented.

> The secondary web app has **no staging slot**. It is a passive disaster-recovery target; slot-based release safety is a primary-region concern already taught in Stage 3. The database is created only on the primary server — the failover group seeds the matching secondary database automatically. Creating it manually would collide with the group.

## Deploy

Export the required secrets and identifiers (never commit them), then deploy with the parameter file:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
export SQL_ENTRA_ADMIN_LOGIN='<entra-user-or-group-display-name>'
export SQL_ENTRA_ADMIN_OBJECT_ID='<entra-object-id>'
export ALERT_EMAIL_ADDRESS='<ops-notification-email>'
export RG='rg-practical-storefront-stage05'
export LOCATION='koreacentral'

az group create --resource-group "$RG" --location "$LOCATION"

az deployment group create \
  --resource-group "$RG" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Prefer the generic driver scripts under `scripts/practical/` for a repeatable deploy → verify → destroy flow:

```bash
scripts/practical/deploy-stage.sh stage-05
scripts/practical/verify-stage.sh stage-05
scripts/practical/destroy-stage.sh stage-05
```

The primary region defaults to `koreacentral` and the secondary to `japaneast`. Override the secondary with the `secondaryLocation` parameter; pick a region that supports Azure SQL failover groups and has App Service S1 capacity.

## Verification note

The `failover-smoke.sh` verification is **read-only**: it confirms the resilience topology exists (two web apps across two regions, two SQL servers, a failover group reporting the `Primary` read-write role, and a Front Door origin group with two priority-ranked origins). It does **not** trigger a failover, because a failover is a stateful operation that belongs in a deliberate drill, not an idempotent smoke test.

The actual failover drill — stopping the primary app, confirming Front Door serves the secondary, then failing the database over with `az sql failover-group set-primary` and failing back — is walked step by step in [`labs/trunk/stage-05-resilience/`](../../../../labs/trunk/stage-05-resilience/).

Front Door endpoints propagate globally over several minutes, so `frontdoor-smoke.sh` treats a non-`200` edge response as a warning. As in earlier stages, the app and slot identities receive the **Key Vault Secrets User** role after the Key Vault reference is created, so a transient secret-resolution failure immediately after deployment is expected while RBAC propagates.

## Outputs

| Output | Purpose |
|---|---|
| `webAppName` | Primary (active) web app name |
| `webAppUrl` | Direct primary origin URL (bypasses Front Door) |
| `secondaryWebAppName` | Secondary (passive) web app name |
| `secondaryWebAppUrl` | Direct secondary origin URL |
| `frontDoorEndpointUrl` | Public Front Door URL for user traffic |
| `frontDoorProfileName` | Front Door profile name |
| `frontDoorEndpointName` | Front Door endpoint name |
| `originGroupName` | Origin group holding both regional origins |
| `autoscaleName` | Autoscale setting on the primary plan |
| `stagingSlotName` | Primary staging slot name |
| `keyVaultName` | Vault holding `SqlConnectionString` |
| `appInsightsName` | For metric queries during verification |
| `sqlServerFqdn` | Primary SQL server FQDN |
| `sqlServerName` | Primary SQL server name |
| `sqlServerSecondaryName` | Secondary SQL server name |
| `failoverGroupName` | Failover group name (and read-write listener label) |
| `failoverListenerFqdn` | Read-write listener FQDN used by both apps |
| `sqlDatabaseName` | Target database name |
| `actionGroupName` | Alert notification group |
| `secondaryLocation` | Secondary Azure region |

## Clean up

```bash
az group delete --name "$RG" --yes --no-wait
```

Deleting the resource group removes both regional stacks and the failover group in one operation.

## See Also

- [Stage 5 — Resilience walkthrough](../../../../docs/practical-journey/stage-05-resilience.md)
- [Stage 4 — Network Isolation infrastructure](../stage-04-network-isolation/)
- [Stage 3 — Scale / Edge infrastructure](../stage-03-scale-edge/)
- [Foundation and data Bicep modules](../../modules/)
