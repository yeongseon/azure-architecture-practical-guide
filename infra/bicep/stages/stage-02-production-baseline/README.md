# Stage 2 Production Baseline Deployment

Use this stage to deploy the full Stage 2 baseline in one resource group: Stage 1 platform services plus Key Vault integration, a staging slot, Microsoft Entra SQL administration, and Azure Monitor alerting.

## Deploy

```bash
az group create \
    --name <resource-group-name> \
    --location koreacentral

az deployment group create \
    --resource-group <resource-group-name> \
    --template-file infra/bicep/stages/stage-02-production-baseline/main.bicep \
    --parameters infra/bicep/stages/stage-02-production-baseline/main.bicepparam \
    --parameters appName=<app-name> \
    --parameters sqlAdminLogin=<sql-admin-login> \
    --parameters sqlAdminPassword=<sql-admin-password> \
    --parameters alertEmail=alerts@example.com
```

## Verify

```bash
az webapp identity show \
    --name <app-name>-web \
    --resource-group <resource-group-name>

az keyvault secret show \
    --vault-name <key-vault-name> \
    --name SqlConnectionString

az sql server ad-admin list \
    --server-name <sql-server-name> \
    --resource-group <resource-group-name>

az webapp deployment slot list \
    --name <app-name>-web \
    --resource-group <resource-group-name>

az webapp deployment slot swap \
    --name <app-name>-web \
    --resource-group <resource-group-name> \
    --slot staging \
    --action preview

az monitor metrics alert list \
    --resource-group <resource-group-name>
```

## Destroy

```bash
az group delete \
    --name <resource-group-name> \
    --yes \
    --no-wait
```
