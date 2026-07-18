---
description: Verify and destroy the Practical Journey stages with the repo scripts — deploy, smoke-test, record outputs, and remove each stage safely.
---

# Verify and Destroy

The Practical Journey ships with three generic driver scripts under `scripts/practical/` so every stage follows the same deploy → verify → destroy rhythm.

## Deploy workflow

Deploy a stage by ID:

```bash
scripts/practical/deploy-stage.sh stage-01
scripts/practical/deploy-stage.sh stage-02
scripts/practical/deploy-stage.sh stage-03
scripts/practical/deploy-stage.sh stage-04
scripts/practical/deploy-stage.sh stage-05
```

What `deploy-stage.sh` does:

1. Loads the stage defaults from `scripts/practical/stages/stage-0N.env`.
2. Verifies that Azure CLI is installed and that `az account show` succeeds.
3. Requires `SQL_ADMIN_PASSWORD` to already exist in the environment.
4. Ensures the target resource group exists, creating it with `az group create` when needed.
5. Runs `az deployment group create` with the stage template, parameter file, and command-line overrides for `appBaseName`, `location`, `sqlAdministratorLogin`, and `sqlAdministratorLoginPassword`.
6. Prints the deployed web app name, public URL, and Application Insights name.
7. Records the deployment name in `scripts/practical/stages/.stage-0N.last-deployment` for later verification.

For Stage 2 and later, the stage parameter files also read `SQL_ENTRA_ADMIN_LOGIN`, `SQL_ENTRA_ADMIN_OBJECT_ID`, and `ALERT_EMAIL_ADDRESS` from the current shell environment.

## Verify workflow

Verify the most recent deployment for a stage:

```bash
scripts/practical/verify-stage.sh stage-01
scripts/practical/verify-stage.sh stage-02
scripts/practical/verify-stage.sh stage-03
scripts/practical/verify-stage.sh stage-04
scripts/practical/verify-stage.sh stage-05
```

What `verify-stage.sh` does:

1. Loads the stage env file and checks Azure login.
2. Reads the recorded deployment name from `scripts/practical/stages/.stage-0N.last-deployment`.
3. Pulls deployment outputs such as `webAppUrl`, `webAppName`, `sqlServerFqdn`, and `sqlDatabaseName` from the group deployment record.
4. Exports those values for the smoke-test scripts.
5. Runs the stage-specific smoke tests listed in `VERIFY_SCRIPTS` inside the matching `stage-0N.env` file.
6. Fails the stage if any smoke test exits non-zero.

## Smoke tests

| Smoke test | What it checks | Used by |
|---|---|---|
| `http-smoke.sh` | `GET /` returns `200`, `/healthz` contains `status`, and `/ops/info` contains `version`. | S1, S2, S3, S4, S5 |
| `sql-smoke.sh` | If `sqlcmd` and SQL credentials are available, runs `SELECT COUNT(*) FROM sys.tables;` against the target database. Otherwise falls back to a TCP 1433 reachability check with `nc`, or warns if neither tool is available. | S1, S2, S3 |
| `identity-smoke.sh` | Confirms the web app has a system-assigned identity, looks for a Key Vault and attempts to read `SqlConnectionString` as an operator warning-only check, confirms a SQL Microsoft Entra admin exists, verifies the `staging` slot exists, attempts a slot swap preview/reset, and checks that metric alerts exist. | S2, S3 |
| `frontdoor-smoke.sh` | Confirms a Front Door profile exists, the endpoint is enabled, a WAF security policy is attached, the origin-group health probe path is `/healthz`, and the autoscale maximum is `2`. An HTTP `200` from the endpoint is treated as best-effort because global propagation can lag. | S3, S4, S5 |
| `private-connectivity-smoke.sh` | Confirms the SQL server has `publicNetworkAccess` set to `Disabled`, a private endpoint exists and is `Approved`, and the SQL private DNS zone exists with at least one virtual network link. | S4 |
| `failover-smoke.sh` | Read-only resilience check: confirms at least two web apps across two regions, at least two SQL logical servers, a failover group whose current read-write role is `Primary`, at least one protected database, and a Front Door origin group with two origins using priorities `1` and `2`. | S5 |

## Stage-to-smoke mapping

| Stage | Smoke tests run by `verify-stage.sh` |
|---|---|
| Stage 1 | `http-smoke.sh`, `sql-smoke.sh` |
| Stage 2 | `http-smoke.sh`, `sql-smoke.sh`, `identity-smoke.sh` |
| Stage 3 | `http-smoke.sh`, `sql-smoke.sh`, `identity-smoke.sh`, `frontdoor-smoke.sh` |
| Stage 4 | `http-smoke.sh`, `frontdoor-smoke.sh`, `private-connectivity-smoke.sh` |
| Stage 5 | `http-smoke.sh`, `frontdoor-smoke.sh`, `failover-smoke.sh` |

## Destroy workflow

Destroy a stage by ID:

```bash
scripts/practical/destroy-stage.sh stage-01
scripts/practical/destroy-stage.sh stage-02
scripts/practical/destroy-stage.sh stage-03
scripts/practical/destroy-stage.sh stage-04
scripts/practical/destroy-stage.sh stage-05
```

What `destroy-stage.sh` does:

1. Loads the stage env file and checks Azure login.
2. Checks whether the target resource group exists.
3. If the resource group is missing, prints a warning and exits cleanly.
4. If the resource group exists, runs `az group delete --resource-group <rg> --yes --no-wait`.
5. Removes the `.stage-0N.last-deployment` marker file so later verification cannot accidentally target a deleted stage.

## Recommended operator sequence

1. Export the required environment variables for the stage you want to run.
2. Run `scripts/practical/deploy-stage.sh stage-0N`.
3. Run `scripts/practical/verify-stage.sh stage-0N` immediately after deployment.
4. Inspect the stage-specific walkthrough page for deeper validation context.
5. Run `scripts/practical/destroy-stage.sh stage-0N` when you are done.

## See Also

- [Practical Journey](index.md)
- [Getting Started](getting-started.md)
- [Cost and Time Model](cost-and-time-model.md)
- [Module Map](module-map.md)

## Sources

- [Bicep parameter files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files)
- [Deploy Bicep files with Azure CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli)
- [Azure resource groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli)
