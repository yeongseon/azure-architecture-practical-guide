# Stage 5 Expected Results

## Verify the Front Door endpoint

```text
GET https://<front-door-endpoint>/ops/info returns HTTP 200 and reports the active Azure region.
```

## Verify the secondary web app exists

```json
[
  {
    "location": "koreacentral",
    "name": "<primary-web-app-name>",
    "state": "Running"
  },
  {
    "location": "japaneast",
    "name": "<secondary-web-app-name>",
    "state": "Running"
  }
]
```

## Verify the failover group policy

```json
{
  "name": "<failover-group-name>",
  "readWriteEndpoint": {
    "failoverPolicy": "Automatic",
    "failoverWithDataLossGracePeriodMinutes": 60
  }
}
```

## Verify SQL role flip

```text
Before failover:
- <primary-sql-server-name> replicationRole = Primary
- <secondary-sql-server-name> replicationRole = Secondary

After failover:
- <primary-sql-server-name> replicationRole = Secondary
- <secondary-sql-server-name> replicationRole = Primary
```

## Verify regional failover through Front Door

```text
After SQL failover completes and the primary web app is stopped, GET https://<front-door-endpoint>/ops/info still returns HTTP 200 and the response shows the secondary region.
```
