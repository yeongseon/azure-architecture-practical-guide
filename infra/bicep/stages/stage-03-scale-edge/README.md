# Stage 3 Scale / Edge Bicep Deployment

Deploy the Stage 3 scale and edge baseline with direct Azure CLI commands that keep Front Door, WAF, autoscale, and the Stage 2 platform services in one resource group.

## Deploy

```bash
az group create --name rg-practical-stage-03-scale-edge-koreacentral --location koreacentral

az deployment group create \
    --resource-group rg-practical-stage-03-scale-edge-koreacentral \
    --template-file infra/bicep/stages/stage-03-scale-edge/main.bicep \
    --parameters infra/bicep/stages/stage-03-scale-edge/main.bicepparam \
    --parameters appName=yourappname \
    --parameters sqlAdminLogin=sqladminuser \
    --parameters sqlAdminPassword=<sql-admin-password> \
    --parameters alertEmail=alerts@example.com
```

## Verify

```bash
export RG=rg-practical-stage-03-scale-edge-koreacentral
export APP_NAME=yourappname

bash scripts/practical/verify/frontdoor-smoke.sh
```

## Destroy

```bash
az group delete \
    --name rg-practical-stage-03-scale-edge-koreacentral \
    --yes \
    --no-wait
```
