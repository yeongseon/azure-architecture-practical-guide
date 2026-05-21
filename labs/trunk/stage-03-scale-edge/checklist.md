# Stage 3 Scale / Edge Checklist

- [ ] Create or select the target resource group in `koreacentral`.
- [ ] Review `infra/bicep/stages/stage-03-scale-edge/main.bicepparam` and replace placeholder values.
- [ ] Run `az bicep build --file infra/bicep/stages/stage-03-scale-edge/main.bicep --stdout` and confirm it succeeds.
- [ ] Run `az deployment group create --resource-group <resource-group-name> --template-file infra/bicep/stages/stage-03-scale-edge/main.bicep --parameters infra/bicep/stages/stage-03-scale-edge/main.bicepparam --parameters appName=<app-name> --parameters sqlAdminLogin=<sql-admin-login> --parameters sqlAdminPassword=<sql-admin-password> --parameters alertEmail=alerts@example.com`.
- [ ] Record the deployment outputs for the Front Door endpoint, web app name, web app URL, and autoscale setting name.
- [ ] Run `curl --silent --output /dev/null --write-out '%{http_code}' https://<front-door-endpoint-host>` and confirm it returns `200`.
- [ ] Run `az afd endpoint show --profile-name <front-door-profile-name> --endpoint-name <front-door-endpoint-name> --resource-group <resource-group-name>` and confirm `enabledState` is `Enabled`.
- [ ] Run `az afd security-policy list --profile-name <front-door-profile-name> --resource-group <resource-group-name>` and confirm at least one security policy exists.
- [ ] Run `az monitor autoscale show --name <autoscale-setting-name> --resource-group <resource-group-name>` and confirm `profiles[0].capacity.maximum` is `2`.
- [ ] Run `az afd origin-group show --profile-name <front-door-profile-name> --origin-group-name app-origin-group --resource-group <resource-group-name>` and confirm the health probe path is `/healthz`.
- [ ] Run `bash scripts/practical/verify/frontdoor-smoke.sh` with `RG` and `APP_NAME` exported and confirm every check passes.
- [ ] Run `az group delete --name <resource-group-name> --yes --no-wait` when you finish the lab.
