# Stage 2 Production Baseline Checklist

- [ ] Create or select the target resource group in `koreacentral`.
- [ ] Review `infra/bicep/stages/stage-02-production-baseline/main.bicepparam` and replace placeholder values.
- [ ] Run `az deployment group create --resource-group <resource-group-name> --template-file infra/bicep/stages/stage-02-production-baseline/main.bicep --parameters infra/bicep/stages/stage-02-production-baseline/main.bicepparam --parameters appName=<app-name> --parameters sqlAdminLogin=<sql-admin-login> --parameters sqlAdminPassword=<sql-admin-password> --parameters alertEmail=alerts@example.com`.
- [ ] Record the deployment outputs for the web app URL, staging slot URL, Key Vault, and SQL server FQDN.
- [ ] Run `az webapp identity show --name <app-name>-web --resource-group <resource-group-name>` and confirm `principalId` exists.
- [ ] Run `az keyvault secret show --vault-name <key-vault-name> --name SqlConnectionString` and confirm the secret exists.
- [ ] Run `az sql server ad-admin list --server-name <sql-server-name> --resource-group <resource-group-name>` and confirm the Entra admin is set.
- [ ] Run `az webapp deployment slot list --name <app-name>-web --resource-group <resource-group-name>` and confirm the `staging` slot exists.
- [ ] Run `az webapp deployment slot swap --name <app-name>-web --resource-group <resource-group-name> --slot staging --action preview` and confirm the preview starts successfully.
- [ ] Run `az monitor metrics alert list --resource-group <resource-group-name>` and confirm the HTTP 5xx alert exists.
- [ ] Run HTTP smoke checks against both the production URL and the staging slot URL.
- [ ] Run `az group delete --name <resource-group-name> --yes --no-wait` when you finish the lab.
