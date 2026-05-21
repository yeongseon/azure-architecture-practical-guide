# Stage 4 Network Isolation Checklist

- [ ] Review the Stage 4 pre-reading links before deployment.
- [ ] Update `infra/bicep/stages/stage-04-network-isolation/main.bicepparam` with the final `appName`, `sqlAdminLogin`, `sqlAdminPassword`, and `alertEmail` values.
- [ ] Create or reuse the target resource group in `koreacentral`.
- [ ] Run `az deployment group create --resource-group <resource-group-name> --template-file infra/bicep/stages/stage-04-network-isolation/main.bicep --parameters infra/bicep/stages/stage-04-network-isolation/main.bicepparam --parameters appName=<app-name> --parameters sqlAdminLogin=<sql-admin-login> --parameters sqlAdminPassword=<sql-admin-password> --parameters alertEmail=alerts@example.com`.
- [ ] Record the deployment outputs for the Front Door endpoint, web app name, virtual network, private endpoint, and SQL server FQDN.
- [ ] Export `RG=<resource-group-name>` and run `bash scripts/practical/verify/private-connectivity-smoke.sh`.
- [ ] Run `az network private-endpoint show --name <private-endpoint-name> --resource-group <resource-group-name>` and confirm the connection state is `Approved`.
- [ ] Run `az sql server show --name <sql-server-name> --resource-group <resource-group-name> --query publicNetworkAccess` and confirm the result is `Disabled`.
- [ ] Run `curl --silent --output /dev/null --write-out '%{http_code}' "https://<front-door-endpoint-hostname>"` and confirm the result is `200`.
- [ ] Run `nslookup <sql-server-name>.database.windows.net` from a resolver in the linked virtual network and confirm the result is a `10.x.x.x` address.
- [ ] Run `az sql db show --name <app-name>-db --server <sql-server-name> --resource-group <resource-group-name>`.
- [ ] Review the Stage 4 deep-dive links after verification.
- [ ] Run `az group delete --name <resource-group-name> --yes --no-wait` when you finish the lab.
