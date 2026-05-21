# Stage 1 MVP Expected Results

## GET /

- Returns HTTP `200`.
- Renders the Practical Storefront home page.

## GET /healthz

- Returns HTTP `200`.
- Returns JSON containing `{"status":"Healthy"}`.

## GET /ops/info

- Returns HTTP `200`.
- Returns JSON with `version`, `region`, and `timestamp` fields.
- `region` reflects `AZURE_REGION` from the web app configuration.

## GET /ops/version

- Returns HTTP `200`.
- Returns JSON containing `{"version":"1.0.0"}`.
