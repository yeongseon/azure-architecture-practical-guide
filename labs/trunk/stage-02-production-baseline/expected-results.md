# Stage 2 Expected Results

## Verify the web app managed identity

```json
{
  "principalId": "<object-id>",
  "tenantId": "<tenant-id>",
  "type": "SystemAssigned",
  "userAssignedIdentities": null
}
```

## Verify the Key Vault secret

```json
{
  "attributes": {
    "enabled": true,
    "recoveryLevel": "Recoverable+Purgeable"
  },
  "contentType": null,
  "id": "https://<key-vault-name>.vault.azure.net/secrets/SqlConnectionString/<secret-version>",
  "name": "SqlConnectionString",
  "value": "Server=tcp:<sql-server-name>.database.windows.net,1433;Initial Catalog=<app-name>-db;..."
}
```

## Verify the SQL Entra administrator

```json
[
  {
    "administratorType": "ActiveDirectory",
    "login": "<deployer-upn-or-principal-name>",
    "sid": "<object-id>",
    "tenantId": "<tenant-id>"
  }
]
```

## Verify the deployment slot

```json
[
  {
    "defaultHostName": "<app-name>-web-staging.azurewebsites.net",
    "name": "staging",
    "state": "Running"
  }
]
```

## Verify slot swap preview

```text
The slot swap preview operation starts successfully and returns an accepted operation response.
```

## Verify the metric alert

```json
[
  {
    "enabled": true,
    "name": "<app-name>-http5xx-alert",
    "scopes": [
      "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Web/sites/<app-name>-web"
    ]
  }
]
```
