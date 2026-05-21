# Stage 4 Expected Results

## Verify the private endpoint

```json
{
  "name": "<private-endpoint-name>",
  "privateLinkServiceConnections": [
    {
      "privateLinkServiceConnectionState": {
        "status": "Approved"
      }
    }
  ]
}
```

## Verify SQL public access is disabled

```text
Disabled
```

## Verify the Front Door endpoint response

```text
200
```

## Verify private DNS resolution from the linked virtual network

```text
Name:    <sql-server-name>.database.windows.net
Address: 10.x.x.x
```

## Verify the SQL database still exists

```json
{
  "name": "<app-name>-db",
  "status": "Online"
}
```
