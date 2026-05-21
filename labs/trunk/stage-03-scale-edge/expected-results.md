# Stage 3 Expected Results

## Verify the Front Door endpoint

```text
curl --silent --output /dev/null --write-out '%{http_code}' https://<front-door-endpoint-host>
200
```

## Verify the Front Door endpoint state

```json
{
  "enabledState": "Enabled",
  "hostName": "<front-door-endpoint-host>",
  "name": "<front-door-endpoint-name>"
}
```

## Verify the WAF security policy attachment

```json
[
  {
    "name": "<front-door-endpoint-name>-waf-policy",
    "parameters": {
      "type": "WebApplicationFirewall"
    }
  }
]
```

## Verify autoscale configuration

```json
{
  "enabled": true,
  "name": "<app-name>-autoscale",
  "profiles": [
    {
      "capacity": {
        "default": "1",
        "maximum": "2",
        "minimum": "1"
      }
    }
  ]
}
```

## Verify the health probe path

```json
{
  "healthProbeSettings": {
    "probePath": "/healthz",
    "probeProtocol": "Https",
    "probeRequestType": "GET"
  },
  "name": "app-origin-group"
}
```
