# Stage 5 — Resilience Expected Results

This document records what a successful Stage 5 deployment and verification looks like. Use it to confirm your run matches the expected active-passive, multi-region architecture.

## Two regional app stacks

```bash
az webapp list \
  --resource-group rg-practical-storefront-stage05 \
  --query "[].{name:name, region:location}" --output table
```

Expected: two web apps in two distinct regions — the primary (`koreacentral`) and the secondary (`japaneast`). The primary carries a staging slot; the secondary is a passive DR target with no slot.

## Two SQL servers, one failover group

```bash
az sql server list \
  --resource-group rg-practical-storefront-stage05 \
  --query "length(@)" --output tsv
```

Expected: `2`. One primary logical server and one secondary logical server.

```bash
az sql failover-group show \
  --name <failoverGroup> \
  --server <primarySqlServer> \
  --resource-group rg-practical-storefront-stage05 \
  --query "{role:replicationRole, databases:length(databases)}" --output table
```

Expected: `replicationRole` is `Primary` and the failover group protects `1` or more databases. The secondary database is seeded by the failover group — it is not deployed directly.

## Front Door prioritized origins

```bash
az afd origin list \
  --origin-group-name <originGroup> \
  --profile-name <frontDoorProfile> \
  --resource-group rg-practical-storefront-stage05 \
  --query "[].{name:name, priority:priority}" --output table
```

Expected: two origins — the primary at priority `1` and the secondary at priority `2`. Front Door routes to the primary while it is healthy and shifts to the secondary only when the primary origin fails its health probe.

## Edge availability

Front Door endpoints propagate globally after deployment. Allow several minutes before the endpoint answers.

```bash
curl -s -o /dev/null -w "%{http_code}" https://<frontDoorEndpoint>/
```

Expected: `200` once propagation completes and the first origin health probe succeeds. A transient `503` or `000` immediately after deployment is expected, not a failure.

## HTTP smoke through the edge

| Request | Expected status | Expected body |
|---|---|---|
| `GET /` (Front Door) | `200` | HTML catalog page listing seeded products |
| `GET /healthz` (Front Door) | `200` | `{"status":"Healthy"}` |
| `GET /ops/info` (Front Door) | `200` | JSON with `version` and `region` fields; `region` is `primary` before failover |
| `POST /Home/Create` (Front Door) | `302` | Redirect on success — the order write reaches SQL through the failover-group listener |

## Failover drill

App-tier and data-tier failover are independent. Stopping the primary web app shifts edge traffic; promoting the secondary SQL server shifts the data tier.

```bash
az webapp stop --name <primaryWebApp> --resource-group rg-practical-storefront-stage05
# wait ~60 seconds for the origin health probe to fail over
curl -s https://<frontDoorEndpoint>/ops/info
```

Expected: after the primary origin is marked unhealthy, `region` reports `secondary`. Front Door has shifted to the priority-2 origin.

```bash
az sql failover-group set-primary \
  --name <failoverGroup> \
  --server <secondarySqlServer> \
  --resource-group rg-practical-storefront-stage05

az sql failover-group show \
  --name <failoverGroup> \
  --server <secondarySqlServer> \
  --resource-group rg-practical-storefront-stage05 \
  --query replicationRole --output tsv
```

Expected: `Primary`. The secondary server now owns the read-write replica.

## Fail back

Restart the primary web app and promote the primary SQL server again.

```bash
az webapp start --name <primaryWebApp> --resource-group rg-practical-storefront-stage05
az sql failover-group set-primary \
  --name <failoverGroup> \
  --server <primarySqlServer> \
  --resource-group rg-practical-storefront-stage05
curl -s https://<frontDoorEndpoint>/ops/info
```

Expected: `region` reports `primary` again and the failover group reports `replicationRole` `Primary` on the primary server.

## Teardown

```bash
az group delete --name rg-practical-storefront-stage05 --yes --no-wait
```

Expected: exit code `0`. Within a few minutes `az group show` for the resource group returns "not found".

## Related

- [Deployment checklist](checklist.md)
- [Sample requests](sample-requests.http)
- [Stage 5 — Resilience walkthrough](../../../docs/practical-journey/stage-05-resilience.md)
