# Practical Storefront

ASP.NET Core 8 MVC sample application used across all five stages of the Practical Journey. It renders a product catalog backed by Azure SQL, accepts orders, and exposes operational endpoints for health and version probes.

## Stack

- ASP.NET Core 8 MVC (Linux)
- Entity Framework Core 8 — Azure SQL in production, in-memory provider for local development and tests

## Project layout

```text
practical-storefront/
├── src/Practical.Storefront.Web/         # MVC web application
├── tests/Practical.Storefront.Web.Tests/ # xUnit integration tests
└── database/                             # schema.sql and seed.sql
```

## Endpoints

| Route | Purpose | Response |
|---|---|---|
| `/` | Product catalog | HTML table of products from the database |
| `/Home/Create` | Order form | Submit a new order |
| `/Home/Orders` | Recent orders | Last 20 orders, newest first |
| `/healthz` | Liveness + SQL connectivity | `{"status":"Healthy"}` |
| `/ops/info` | Build metadata | `{"version":"...","region":"..."}` |
| `/ops/version` | Build version | `{"version":"..."}` |

`/ops/info` reads the region from the `REGION` environment variable and falls back to `local` when unset.

## Run locally

No database is required for development — the app uses the in-memory provider and seeds sample products on startup when no connection string is configured.

```bash
cd src/practical-storefront
dotnet run --project src/Practical.Storefront.Web
```

Then browse to the printed `https://localhost:<port>/` URL.

## Run against Azure SQL

Provide a connection string via configuration or environment variable. The app switches to the SQL Server provider automatically when the string is non-empty.

```bash
export ConnectionStrings__StorefrontDb="Server=tcp:<server>.database.windows.net,1433;Database=<db>;Authentication=Active Directory Default;Encrypt=True;"
dotnet run --project src/Practical.Storefront.Web
```

Apply the schema and seed data with the scripts under `database/`:

```bash
sqlcmd -S <server>.database.windows.net -d <db> -G -i database/schema.sql
sqlcmd -S <server>.database.windows.net -d <db> -G -i database/seed.sql
```

## Build and test

```bash
cd src/practical-storefront
dotnet build
dotnet test
```

## Verify endpoints

```bash
curl -s http://localhost:5000/healthz
curl -s http://localhost:5000/ops/info
curl -s http://localhost:5000/ops/version
```
