# Stage 4 — Network Isolation Expected Results

This document records what a successful Stage 4 deployment and verification looks like. Use it to confirm your run matches the expected private-data-path architecture.

## SQL public access disabled

```bash
az sql server show \
  --name <sqlServer> \
  --resource-group rg-practical-storefront-stage04 \
  --query publicNetworkAccess --output tsv
```

Expected: `Disabled`. The database no longer accepts connections from the public internet.

## Private endpoint approved

```bash
az network private-endpoint show \
  --name <sqlPrivateEndpoint> \
  --resource-group rg-practical-storefront-stage04 \
  --query "privateLinkServiceConnections[0].privateLinkServiceConnectionState.status" --output tsv
```

Expected: `Approved`. The private endpoint has an active connection to the SQL logical server.

## Private DNS zone and VNet link

```bash
az network private-dns zone show \
  --name privatelink.database.windows.net \
  --resource-group rg-practical-storefront-stage04 \
  --query name --output tsv

az network private-dns link vnet list \
  --zone-name privatelink.database.windows.net \
  --resource-group rg-practical-storefront-stage04 \
  --query "length(@)" --output tsv
```

Expected: the zone name is returned, and the link count is `1` or more.

## Private name resolution from the app

From the App Service SSH/Kudu console:

```bash
nslookup <sqlServer>.database.windows.net
```

Expected: resolves to a `10.10.2.x` address in the private-endpoint subnet — not a public Azure SQL IP. This proves the app takes the private path.

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
| `GET /ops/info` (Front Door) | `200` | JSON with `version` and `region` fields |
| `POST /Home/Create` (Front Door) | `302` | Redirect on success — the order write reaches SQL over the private endpoint |

## Teardown

```bash
az group delete --name rg-practical-storefront-stage04 --yes --no-wait
```

Expected: exit code `0`. Within a few minutes `az group show` for the resource group returns "not found".

## Related

- [Deployment checklist](checklist.md)
- [Sample requests](sample-requests.http)
- [Stage 4 — Network Isolation walkthrough](../../../docs/practical-journey/stage-04-network-isolation.md)
