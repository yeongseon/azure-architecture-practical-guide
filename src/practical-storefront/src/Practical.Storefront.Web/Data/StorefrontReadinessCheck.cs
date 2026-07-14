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
            var hasCatalog = await _db.Products.AsNoTracking().AnyAsync(cancellationToken);
            return hasCatalog
                ? HealthCheckResult.Healthy("Catalog reachable and seeded.")
                : HealthCheckResult.Unhealthy("Catalog schema reachable but no products found.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Catalog query failed.", ex);
        }
    }
}
