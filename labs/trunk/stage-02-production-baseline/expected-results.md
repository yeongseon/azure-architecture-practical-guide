# Stage 2 — Production Baseline Expected Results

This document records what a successful Stage 2 deployment and verification looks like. Use it to confirm your run matches the expected baseline.

## HTTP smoke test

| Request | Expected status | Expected body |
|---|---|---|
| `GET /` | `200` | HTML catalog page listing seeded products |
| `GET /healthz` | `200` | `{"status":"Healthy"}` |
| `GET /ops/info` | `200` | JSON with `version` and `region` fields |
| `GET /ops/version` | `200` | JSON with a `version` field |
| `POST /Home/Create` | `302` | Redirect to the orders page on success |

## Identity and secret custody

- `az webapp identity show` reports a non-empty `principalId`:

```bash
az webapp identity show \
  --name <webAppName> \
  --resource-group rg-practical-storefront-stage02 \
  --query principalId --output tsv
```

Expected: a GUID, not empty.

- The SQL connection string lives in Key Vault:

```bash
az keyvault secret show \
  --vault-name <keyVaultName> \
  --name SqlConnectionString \
  --query id --output tsv
```

Expected: exit code `0` and a secret identifier URL.

- The web app setting is a Key Vault reference, not a raw secret:

```bash
az webapp config appsettings list \
  --name <webAppName> \
  --resource-group rg-practical-storefront-stage02 \
  --query "[?name=='ConnectionStrings__StorefrontDb'].value" --output tsv
```

Expected: a value beginning with `@Microsoft.KeyVault(SecretUri=`.

## SQL Entra administrator

```bash
az sql server ad-admin list \
  --server-name <sqlServer> \
  --resource-group rg-practical-storefront-stage02 \
  --query "[].login" --output tsv
```

Expected: the Entra principal display name you supplied.

## Release safety

```bash
az webapp deployment slot list \
  --name <webAppName> \
  --resource-group rg-practical-storefront-stage02 \
  --query "[].name" --output tsv
```

Expected: the list contains `staging`.

```bash
az webapp deployment slot swap \
  --name <webAppName> \
  --resource-group rg-practical-storefront-stage02 \
  --slot staging --action preview
```

Expected: exit code `0` (preview succeeds).

## Alerting

```bash
az monitor metrics alert list \
  --resource-group rg-practical-storefront-stage02 \
  --query "length(@)" --output tsv
```

Expected: `2` — one Http5xx alert and one response-time alert, both wired to the action group.

## Teardown

```bash
az group delete --name rg-practical-storefront-stage02 --yes --no-wait
```

Expected: exit code `0`. Within a few minutes `az group show` for the resource group returns "not found".

## Related

- [Deployment checklist](checklist.md)
- [Sample requests](sample-requests.http)
- [Stage 2 — Production Baseline walkthrough](../../../docs/practical-journey/stage-02-production-baseline.md)
