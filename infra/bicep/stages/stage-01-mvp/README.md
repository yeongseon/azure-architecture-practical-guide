# Stage 1 MVP Bicep Deployment

Deploy the Stage 1 MVP baseline with the shared practical journey scripts.

## Deploy

```bash
bash scripts/practical/deploy-stage.sh scripts/practical/stages/stage-01.env
```

## Verify

```bash
bash scripts/practical/verify-stage.sh scripts/practical/stages/stage-01.env
```

## Destroy

```bash
bash scripts/practical/destroy-stage.sh scripts/practical/stages/stage-01.env
```

## Manual deployment example

```bash
az group create --name rg-practical-stage-01-mvp-koreacentral --location koreacentral
az deployment group create --resource-group rg-practical-stage-01-mvp-koreacentral --template-file infra/bicep/stages/stage-01-mvp/main.bicep --parameters infra/bicep/stages/stage-01-mvp/main.bicepparam
```

## Manual verification example

```bash
az deployment group show --resource-group rg-practical-stage-01-mvp-koreacentral --name main
az group show --name rg-practical-stage-01-mvp-koreacentral
```

## Manual destroy example

```bash
az group delete --name rg-practical-stage-01-mvp-koreacentral --yes --no-wait
```
