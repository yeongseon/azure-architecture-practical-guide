# Stage 5 Resilience Bicep Deployment

Deploy the Stage 5 resilience baseline in a **single resource group** even though resources span a primary and secondary Azure region. The resource group location is metadata only; the individual resources still deploy into `location` and `secondaryLocation`.

## Deploy

```bash
az group create \
    --name <resource-group-name> \
    --location koreacentral

az deployment group create \
    --resource-group <resource-group-name> \
    --template-file infra/bicep/stages/stage-05-resilience/main.bicep \
    --parameters infra/bicep/stages/stage-05-resilience/main.bicepparam \
    --parameters appName=<app-name> \
    --parameters sqlAdminLogin=<sql-admin-login> \
    --parameters sqlAdminPassword=<sql-admin-password> \
    --parameters alertEmail=alerts@example.com
```

## Verify

```bash
az deployment group show \
    --resource-group <resource-group-name> \
    --name main

bash scripts/practical/verify/failover-smoke.sh scripts/practical/stages/stage-05.env
```

## Destroy

```bash
az group delete \
    --name <resource-group-name> \
    --yes \
    --no-wait
```
