# Stage 5 Resilience Checklist

- [ ] Create or select the target resource group in `koreacentral`.
- [ ] Review `infra/bicep/stages/stage-05-resilience/main.bicepparam` and replace placeholder values.
- [ ] Run `az deployment group create --resource-group <resource-group-name> --template-file infra/bicep/stages/stage-05-resilience/main.bicep --parameters infra/bicep/stages/stage-05-resilience/main.bicepparam --parameters appName=<app-name> --parameters sqlAdminLogin=<sql-admin-login> --parameters sqlAdminPassword=<sql-admin-password> --parameters alertEmail=alerts@example.com`.
- [ ] Record the Front Door endpoint, primary web app name, secondary web app name, failover group name, and read-write listener endpoint.
- [ ] Run `az afd profile list --resource-group <resource-group-name>` and confirm Azure Front Door exists.
- [ ] Run `az webapp list --resource-group <resource-group-name>` and confirm both web apps exist in different Azure regions.
- [ ] Run `az sql failover-group show --name <failover-group-name> --resource-group <resource-group-name> --server <primary-sql-server-name>` and confirm automatic failover with a 60-minute grace period.
- [ ] Run `bash scripts/practical/verify/failover-smoke.sh scripts/practical/stages/stage-05.env`.
- [ ] Confirm Front Door failed over to the secondary region after the primary web app stop event.
- [ ] Confirm SQL replication roles flipped during the failover test and returned to the original primary after cleanup.
- [ ] Run `az group delete --name <resource-group-name> --yes --no-wait` when you finish the lab.
