using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Data;

public class StorefrontDbContext : DbContext
{
    public StorefrontDbContext(DbContextOptions<StorefrontDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products => Set<Product>();

    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.Property(p => p.Price).HasColumnType("decimal(18,2)");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasOne(o => o.Product)
                .WithMany()
                .HasForeignKey(o => o.ProductId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
