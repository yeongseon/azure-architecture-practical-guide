# Stage 1 — MVP Infrastructure

This directory deploys the Stage 1 MVP baseline for the **Practical Storefront** journey: a public ASP.NET Core web app backed by Azure SQL Database, with telemetry from day one.

## What gets deployed

| Resource | Module | SKU / Tier | Notes |
|---|---|---|---|
| Log Analytics workspace | `foundation/log-analytics-workspace.bicep` | PerGB2018, 7-day retention | Telemetry backend |
| Application Insights | `foundation/application-insights.bicep` | Workspace-based | Wired to the web app |
| App Service plan | `web/app-service-plan.bicep` | Linux **B1** (Basic) | Single worker |
| Web App | `web/web-app.bicep` | `DOTNETCORE\|8.0` | HTTPS-only, system-assigned identity |
| SQL logical server | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | `publicNetworkAccess: Enabled` for Stage 1 |
| SQL Database | `data/sql-database.bicep` | **Basic** | 2 GB max |
| SQL firewall rule | inline (`AllowAllWindowsAzureIps`) | `0.0.0.0` | Lets Azure services reach SQL |

Estimated cost: **~$0.09–$0.13/hour**. Deploy time: **20–30 minutes**.

## Design intent

- **Managed PaaS over VMs** — App Service and Azure SQL, no infrastructure to patch.
- **Stateless app** — all state lives in SQL; the app can scale out later without change.
- **Telemetry on day 1** — Application Insights connection string is injected at deploy time.
- **Single resource group** — the whole stage tears down with one `az group delete`.

> Stage 1 uses SQL authentication and a public SQL endpoint for simplicity. Later stages migrate to managed identity, Key Vault, and private endpoints. Do not treat this connection-string pattern as a production target.

## Deploy

Set the SQL admin password (never commit it) and deploy with the parameter file:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
export RG='rg-practical-storefront-stage01'
export LOCATION='koreacentral'

az group create --resource-group "$RG" --location "$LOCATION"

az deployment group create \
  --resource-group "$RG" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Prefer the generic driver scripts under `scripts/practical/` for a repeatable deploy → verify → destroy flow:

```bash
scripts/practical/deploy-stage.sh stage-01
scripts/practical/verify-stage.sh stage-01
scripts/practical/destroy-stage.sh stage-01
```

## Outputs

| Output | Purpose |
|---|---|
| `webAppName` | Name of the web app |
| `webAppUrl` | Public HTTPS URL |
| `appInsightsName` | For metric queries during verification |
| `sqlServerFqdn` | For SQL connectivity smoke tests |
| `sqlDatabaseName` | Target database name |

## Clean up

```bash
az group delete --name "$RG" --yes --no-wait
```

## See Also

- [Stage 1 — MVP walkthrough](../../../../docs/practical-journey/stage-01-mvp.md)
- [Foundation Bicep modules](../../modules/)
