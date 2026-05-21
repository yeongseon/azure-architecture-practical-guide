# Practical Storefront

Simple ASP.NET Core 8 MVC sample used by the Azure Architecture Practical Guide.

## Prerequisites

- .NET 8 SDK

## Local run

```bash
dotnet run --project src/Practical.Storefront.Web
```

## Run tests

```bash
dotnet test
```

## Environment variables

- `AZURE_REGION`: Sets the region value returned by `/ops/info`
- `ConnectionStrings__DefaultConnection`: Uses SQL Server when set; otherwise the app uses local SQLite
