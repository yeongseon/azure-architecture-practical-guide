# Stage 4 Network Isolation Deployment

Use this stage to deploy the full Stage 4 baseline in one resource group: Stage 3 public web, observability, alerting, edge, and autoscale resources plus virtual network integration, Azure SQL Private Endpoint, and private DNS.

## Deploy

```bash
az deployment group create \
    --resource-group <resource-group-name> \
    --template-file infra/bicep/stages/stage-04-network-isolation/main.bicep \
    --parameters infra/bicep/stages/stage-04-network-isolation/main.bicepparam \
    --parameters appName=<app-name> \
    --parameters sqlAdminLogin=<sql-admin-login> \
    --parameters sqlAdminPassword=<sql-admin-password> \
    --parameters alertEmail=alerts@example.com
```

## Verify

```bash
export RG=<resource-group-name>
bash scripts/practical/verify/private-connectivity-smoke.sh
```

Manual checks:

```bash
az network private-endpoint show \
    --name <private-endpoint-name> \
    --resource-group <resource-group-name>

az sql server show \
    --name <sql-server-name> \
    --resource-group <resource-group-name> \
    --query publicNetworkAccess

curl --silent --output /dev/null --write-out '%{http_code}' "https://<front-door-endpoint>"
```

## Destroy

```bash
az group delete \
    --name <resource-group-name> \
    --yes \
    --no-wait
```
