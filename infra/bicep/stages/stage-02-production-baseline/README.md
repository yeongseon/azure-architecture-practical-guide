# Stage 2 — Production Baseline Infrastructure

This directory deploys the Stage 2 baseline for the **Practical Storefront** journey. It builds on Stage 1 and adds the four things an app needs once it starts to matter to the business: **identity hygiene**, **secret custody**, **release safety**, and **alerting**.

## What gets deployed

| Resource | Module | SKU / Tier | Notes |
|---|---|---|---|
| Log Analytics workspace | `foundation/log-analytics-workspace.bicep` | PerGB2018, 30-day retention | Longer retention than Stage 1 |
| Application Insights | `foundation/application-insights.bicep` | Workspace-based | Wired to app and slot |
| App Service plan | `web/app-service-plan.bicep` | Linux **S1** (Standard) | Enables deployment slots |
| Web App | `web/web-app.bicep` | `DOTNETCORE\|8.0` | System-assigned managed identity |
| Staging slot | `web/web-app-slot.bicep` | Shares the S1 plan | Safe pre-production releases |
| Key Vault | `foundation/key-vault.bicep` | Standard, RBAC | Custody of the SQL connection string |
| SQL logical server | `data/sql-logical-server.bicep` | v12.0, TLS 1.2 | `publicNetworkAccess: Enabled` |
| SQL Database | `data/sql-database.bicep` | **Basic** | 2 GB max |
| SQL Entra admin | inline (`administrators`) | ActiveDirectory | Foundation for passwordless SQL |
| Action Group | `foundation/action-group.bicep` | Email receiver | Alert notification target |
| Metric alerts | `foundation/metric-alerts.bicep` | Http5xx, HttpResponseTime | Tied to the action group |
| Key Vault role assignments | `foundation/role-assignment.bicep` | Key Vault Secrets User | Granted to app and slot identities |

Estimated cost: **~$0.14–$0.20/hour**. Deploy time: **25–40 minutes**.

## Design intent

- **Identity before secrets** — the web app and slot use system-assigned managed identities. The SQL connection string is stored in Key Vault, and the app reads it through a Key Vault reference (`@Microsoft.KeyVault(...)`), so no secret sits in app configuration.
- **Secret custody** — Key Vault (RBAC-authorized) holds `SqlConnectionString`. Access is granted by role assignment, not access policies.
- **Release safety** — a staging slot lets you deploy, validate, and swap without downtime.
- **Alerting tied to signals** — 5xx errors and response-time regressions notify an action group.

> Stage 2 sets the SQL **Microsoft Entra administrator** and gives the app a managed identity, laying the groundwork for passwordless SQL. The app still authenticates to SQL with the connection string held in Key Vault at this stage; fully passwordless app-to-SQL (a contained database user created `FROM EXTERNAL PROVIDER`) is completed in a later stage. The public SQL endpoint and public Key Vault endpoint are also tightened to private endpoints in a later stage.

## Deploy

Export the required secrets and identifiers (never commit them), then deploy with the parameter file:

```bash
export SQL_ADMIN_PASSWORD='<choose-a-strong-password>'
export SQL_ENTRA_ADMIN_LOGIN='<entra-user-or-group-display-name>'
export SQL_ENTRA_ADMIN_OBJECT_ID='<entra-object-id>'
export ALERT_EMAIL_ADDRESS='<ops-notification-email>'
export RG='rg-practical-storefront-stage02'
export LOCATION='koreacentral'

az group create --resource-group "$RG" --location "$LOCATION"

az deployment group create \
  --resource-group "$RG" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Prefer the generic driver scripts under `scripts/practical/` for a repeatable deploy → verify → destroy flow:

```bash
scripts/practical/deploy-stage.sh stage-02
scripts/practical/verify-stage.sh stage-02
scripts/practical/destroy-stage.sh stage-02
```

## Operator prerequisites

- To read the Key Vault secret yourself (`az keyvault secret show`), your principal needs the **Key Vault Secrets User** (or Officer) role on the vault. The deploying identity does not receive it automatically.
- The Entra admin object ID must belong to a user, group, or service principal in the same tenant.

## Outputs

| Output | Purpose |
|---|---|
| `webAppName` | Name of the web app |
| `webAppUrl` | Public HTTPS URL |
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

- [Stage 2 — Production Baseline walkthrough](../../../../docs/practical-journey/stage-02-production-baseline.md)
- [Stage 1 — MVP infrastructure](../stage-01-mvp/)
- [Foundation Bicep modules](../../modules/)
