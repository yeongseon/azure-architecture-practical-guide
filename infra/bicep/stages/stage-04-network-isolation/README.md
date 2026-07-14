# Stage 4 — Network Isolation Infrastructure

This directory deploys the Stage 4 architecture for the **Practical Storefront** journey. It builds on the [Stage 3](../stage-03-scale-edge/) scale-and-edge baseline and adds the one thing a compliance-bound workload needs: a **private data path**. The database stops accepting public connections, and the web app reaches it over a Private Endpoint through regional VNet integration.

## What gets deployed

Stage 4 is self-contained: it deploys the full Stage 3 stack plus the network isolation resources below, so it can stand up in a fresh resource group on its own.

| Resource | Module | SKU / Tier | Notes |
|---|---|---|---|
| Virtual network | `network/virtual-network.bicep` | `10.10.0.0/16` | Two subnets |
| Integration subnet | `network/virtual-network.bicep` | `10.10.1.0/24` | Delegated to `Microsoft.Web/serverFarms` |
| Private endpoint subnet | `network/virtual-network.bicep` | `10.10.2.0/24` | `privateEndpointNetworkPolicies: Disabled` |
| Private DNS zone | `network/private-dns-zone.bicep` | `privatelink.database.windows.net` | Linked to the VNet |
| SQL Private Endpoint | `network/private-endpoint-sql.bicep` | `sqlServer` group | Registered in the private DNS zone |
| App Service VNet integration | inline (`sites/networkConfig`) | Swift | App joins the integration subnet |
| Log Analytics workspace | `foundation/log-analytics-workspace.bicep` | PerGB2018, 30-day retention | Telemetry backend |
| Application Insights | `foundation/application-insights.bicep` | Workspace-based | Wired to app and slot |
| App Service plan | `web/app-service-plan.bicep` | Linux **S1** (Standard) | Autoscale-capable host |
| Web App | `web/web-app.bicep` | `DOTNETCORE\|8.0` | `WEBSITE_VNET_ROUTE_ALL=1` routes egress through the VNet |
| Staging slot | `web/web-app-slot.bicep` | Shares the S1 plan | Safe pre-production releases |
| Key Vault | `foundation/key-vault.bicep` | Standard, RBAC | Custody of the SQL connection string |
| SQL logical server | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | **`publicNetworkAccess: Disabled`** |
| SQL Database | `data/sql-database.bicep` | **Basic** | 2 GB max |
| SQL Entra admin | inline (`administrators`) | ActiveDirectory | Foundation for passwordless SQL |
| Action Group | `foundation/action-group.bicep` | Email receiver | Alert notification target |
| Metric alerts | `foundation/metric-alerts.bicep` | Http5xx, HttpResponseTime | Tied to the action group |
| Key Vault role assignments | `foundation/key-vault-role-assignment.bicep` | Key Vault Secrets User | Granted to app and slot identities, scoped to the vault |
| Autoscale setting | `foundation/autoscale-settings.bicep` | CPU-based, min 1 / max 2 | Scales the S1 plan out and back in |
| Front Door profile + WAF | `web/front-door-standard.bicep` | Standard_AzureFrontDoor | Global edge entry point, Prevention mode |
| Origin group + origin + route | inline (`Microsoft.Cdn`) | Health probe `/healthz` | Routes edge traffic to the web app |

Estimated cost: **~$0.24–$0.36/hour**. Deploy time: **35–55 minutes**.

## Design intent

- **Separate public ingress from private data** — user traffic still enters through Front Door over the public edge, but the database tier no longer has a public face. The two concerns are decoupled: the front is deliberately reachable, the data tier deliberately is not.
- **Lock down the data tier first** — `publicNetworkAccess` on the SQL logical server is set to `Disabled`. The only network path into the database is the Private Endpoint in the private-endpoint subnet. The public firewall rules from earlier stages are removed because they no longer apply.
- **Private DNS is architecture, not an afterthought** — the `privatelink.database.windows.net` zone is created and linked to the VNet in the same template. Without the zone link, the web app would resolve the SQL FQDN to its public IP and the private endpoint would never be used. DNS is what makes the private path actually take effect.
- **Regional VNet integration for egress** — the web app joins a delegated subnet and `WEBSITE_VNET_ROUTE_ALL=1` forces its outbound traffic through the VNet, so DNS resolution and the SQL connection travel the private path.

> The web app origin is still reached by Front Door over its public hostname at this stage. Fronting the origin privately (Private Endpoint on the web app plus origin lockdown by `X-Azure-FDID` and the `AzureFrontDoor.Backend` service tag) is a later stage. Stage 4 isolates the **data tier**, not the compute ingress.

## Deploy

Export the required secrets and identifiers (never commit them), then deploy with the parameter file:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
export SQL_ENTRA_ADMIN_LOGIN='<entra-user-or-group-display-name>'
export SQL_ENTRA_ADMIN_OBJECT_ID='<entra-object-id>'
export ALERT_EMAIL_ADDRESS='<ops-notification-email>'
export RG='rg-practical-storefront-stage04'
export LOCATION='koreacentral'

az group create --resource-group "$RG" --location "$LOCATION"

az deployment group create \
  --resource-group "$RG" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Prefer the generic driver scripts under `scripts/practical/` for a repeatable deploy → verify → destroy flow:

```bash
scripts/practical/deploy-stage.sh stage-04
scripts/practical/verify-stage.sh stage-04
scripts/practical/destroy-stage.sh stage-04
```

## Verification note

Because SQL public network access is `Disabled`, the deploy host can no longer reach the database over the internet. The `sql-smoke.sh` public-endpoint test is intentionally **dropped** from this stage's verification set. Instead, `private-connectivity-smoke.sh` verifies the control-plane facts that prove the private path exists: the SQL server reports `publicNetworkAccess: Disabled`, the private endpoint connection is `Approved`, and the `privatelink.database.windows.net` DNS zone is present and linked to the VNet. Front Door endpoints still propagate globally over several minutes, so `frontdoor-smoke.sh` treats a non-`200` edge response as a warning.

Confirming that the app resolves the SQL FQDN to a `10.x.x.x` address requires running `nslookup` from inside the App Service (Kudu/SSH), which is a runtime check performed against a live deployment rather than a control-plane smoke test.

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
| `sqlServerFqdn` | SQL server FQDN (resolves privately from the app) |
| `sqlServerName` | SQL server name |
| `sqlDatabaseName` | Target database name |
| `actionGroupName` | Alert notification group |
| `vnetName` | Stage virtual network |
| `sqlPrivateEndpointName` | SQL private endpoint |
| `sqlPrivateDnsZoneName` | SQL private DNS zone |

## Clean up

```bash
az group delete --name "$RG" --yes --no-wait
```

## See Also

- [Stage 4 — Network Isolation walkthrough](../../../../docs/practical-journey/stage-04-network-isolation.md)
- [Stage 3 — Scale / Edge infrastructure](../stage-03-scale-edge/)
- [Foundation and network Bicep modules](../../modules/)
