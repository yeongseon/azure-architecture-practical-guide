# Stage 3 — Scale / Edge Expected Results

This document records what a successful Stage 3 deployment and verification looks like. Use it to confirm your run matches the expected edge-and-scale architecture.

## Edge availability

Front Door endpoints propagate globally after deployment. Allow several minutes before the endpoint answers.

```bash
curl -s -o /dev/null -w "%{http_code}" https://<frontDoorEndpoint>/
```

Expected: `200` once propagation completes and the first origin health probe succeeds. A transient `503` or `000` immediately after deployment is expected, not a failure.

## Endpoint state

```bash
az afd endpoint show \
  --profile-name <afdProfile> \
  --endpoint-name <afdEndpoint> \
  --resource-group rg-practical-storefront-stage03 \
  --query enabledState --output tsv
```

Expected: `Enabled`.

## WAF security policy

```bash
az afd security-policy list \
  --profile-name <afdProfile> \
  --resource-group rg-practical-storefront-stage03 \
  --query "length(@)" --output tsv
```

Expected: `1` or more — a WAF policy in Prevention mode associated with the endpoint.

## Health-probed routing

```bash
az afd origin-group show \
  --profile-name <afdProfile> \
  --origin-group-name og-storefront \
  --resource-group rg-practical-storefront-stage03 \
  --query healthProbeSettings.probePath --output tsv
```

Expected: `/healthz`.

## Autoscale

```bash
az monitor autoscale show \
  --name <autoscaleName> \
  --resource-group rg-practical-storefront-stage03 \
  --query "profiles[0].capacity.maximum" --output tsv
```

Expected: `2` — the App Service plan scales between 1 and 2 instances on average CPU.

## HTTP smoke through the edge

| Request | Expected status | Expected body |
|---|---|---|
| `GET /` (Front Door) | `200` | HTML catalog page listing seeded products |
| `GET /healthz` (Front Door) | `200` | `{"status":"Healthy"}` |
| `GET /ops/info` (Front Door) | `200` | JSON with `version` and `region` fields |
| `GET /?id=1 OR 1=1--` | `403` | Blocked by the WAF managed rule set |

## Teardown

```bash
az group delete --name rg-practical-storefront-stage03 --yes --no-wait
```

Expected: exit code `0`. Within a few minutes `az group show` for the resource group returns "not found".

## Related

- [Deployment checklist](checklist.md)
- [Sample requests](sample-requests.http)
- [Stage 3 — Scale / Edge walkthrough](../../../docs/practical-journey/stage-03-scale-edge.md)
