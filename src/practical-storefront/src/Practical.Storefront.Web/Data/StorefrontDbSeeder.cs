using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Data;

public static class StorefrontDbSeeder
{
    public static async Task SeedAsync(StorefrontDbContext dbContext)
    {
        if (await dbContext.Products.AnyAsync())
        {
            return;
        }

        var products = new[]
        {
            new Product { Name = "Azure Architecture Book", Description = "Hands-on reference for platform decisions, landing zones, and workload design.", Price = 39.00m, ImageUrl = "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=900&q=80", IsAvailable = true },
            new Product { Name = "Cloud Design Poster", Description = "Large-format architecture poster for reviewing reliability and security trade-offs.", Price = 24.00m, ImageUrl = "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80", IsAvailable = true },
            new Product { Name = "Well-Architected Checklist Cards", Description = "Desk-friendly checklist cards for architecture reviews and remediation planning.", Price = 18.50m, ImageUrl = "https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=900&q=80", IsAvailable = true },
            new Product { Name = "Azure Landing Zone Workbook", Description = "Workshop workbook for subscription design, policy guardrails, and governance setup.", Price = 29.00m, ImageUrl = "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80", IsAvailable = true },
            new Product { Name = "Resilience Review Toolkit", Description = "Scenario cards for failure testing, region failover planning, and recovery drills.", Price = 32.00m, ImageUrl = "https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=900&q=80", IsAvailable = true },
            new Product { Name = "FinOps Estimation Pack", Description = "Simple worksheets for cost estimation, rightsizing, and optimization reviews.", Price = 21.75m, ImageUrl = "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=900&q=80", IsAvailable = true }
        };

        await dbContext.Products.AddRangeAsync(products);
        await dbContext.SaveChangesAsync();
    }
}
