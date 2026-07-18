using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Data;

public static class SeedData
{
    public static void Initialize(StorefrontDbContext context)
    {
        if (context.Products.Any())
        {
            return;
        }

        context.Products.AddRange(
            new Product { Name = "Practical Notebook", Description = "A5 dotted notebook for architects.", Price = 12.50m },
            new Product { Name = "Cloud Sticker Pack", Description = "Set of 10 Azure service stickers.", Price = 6.00m },
            new Product { Name = "Bicep T-Shirt", Description = "Infrastructure-as-code themed tee.", Price = 24.99m },
            new Product { Name = "Container Mug", Description = "350ml ceramic mug with a whale.", Price = 14.00m });

        context.SaveChanges();
    }
}
