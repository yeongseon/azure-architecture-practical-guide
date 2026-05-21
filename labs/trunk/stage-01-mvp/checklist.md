# Stage 1 MVP Checklist

- [ ] Review the Stage 1 pre-reading links.
- [ ] Update `infra/bicep/stages/stage-01-mvp/main.bicepparam` with a unique `appName`.
- [ ] Update `infra/bicep/stages/stage-01-mvp/main.bicepparam` with a secure `sqlAdminPassword`.
- [ ] Confirm Azure CLI access with `az account show`.
- [ ] Run `bash scripts/practical/deploy-stage.sh scripts/practical/stages/stage-01.env`.
- [ ] Capture the deployed web app URL from deployment outputs.
- [ ] Run `bash scripts/practical/verify-stage.sh scripts/practical/stages/stage-01.env`.
- [ ] Run the manual Application Insights metric query from the Stage 1 guide.
- [ ] Review the Stage 1 deep-dive links.
- [ ] Run `bash scripts/practical/destroy-stage.sh scripts/practical/stages/stage-01.env`.
- [ ] Confirm the resource group no longer exists.
