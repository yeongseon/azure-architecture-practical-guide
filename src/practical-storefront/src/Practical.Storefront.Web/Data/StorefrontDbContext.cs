using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Data;

public class StorefrontDbContext(DbContextOptions<StorefrontDbContext> options) : DbContext(options)
{
    public DbSet<Product> Products => Set<Product>();

    public DbSet<Order> Orders => Set<Order>();

    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Product>(entity =>
        {
            entity.Property(product => product.Name).HasMaxLength(120);
            entity.Property(product => product.Description).HasMaxLength(600);
            entity.Property(product => product.ImageUrl).HasMaxLength(500);
            entity.Property(product => product.Price).HasColumnType("decimal(18,2)");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.Property(order => order.CustomerName).HasMaxLength(120);
            entity.Property(order => order.CustomerEmail).HasMaxLength(200);
            entity.Property(order => order.TotalAmount).HasColumnType("decimal(18,2)");
            entity.HasMany(order => order.Items)
                .WithOne()
                .HasForeignKey(item => item.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.Property(item => item.ProductName).HasMaxLength(120);
            entity.Property(item => item.UnitPrice).HasColumnType("decimal(18,2)");
        });
    }
}
