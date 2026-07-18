using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Practical.Storefront.Web.Data;

public class StorefrontReadinessCheck : IHealthCheck
{
    private readonly StorefrontDbContext _db;

    public StorefrontReadinessCheck(StorefrontDbContext db)
    {
        _db = db;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Readiness is a database *connectivity* check (issue #13): the catalog
            // schema must be reachable. An empty (not-yet-seeded) table is still
            // healthy — a freshly-created database before seed.sql must not fail /healthz.
            var productCount = await _db.Products.AsNoTracking().CountAsync(cancellationToken);
            return HealthCheckResult.Healthy(
                productCount > 0
                    ? $"Catalog reachable and seeded ({productCount} products)."
                    : "Catalog schema reachable but not yet seeded.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Catalog query failed.", ex);
        }
    }
}
