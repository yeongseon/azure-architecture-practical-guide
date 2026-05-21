using System.Collections.Generic;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Practical.Storefront.Web.Data;

namespace Practical.Storefront.Web.Tests;

public sealed class StorefrontApplicationFactory : WebApplicationFactory<Program>
{
    private SqliteConnection? connection;

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        Environment.SetEnvironmentVariable("AZURE_REGION", "test-region");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<DbContextOptions<StorefrontDbContext>>();
            services.RemoveAll<StorefrontDbContext>();

            connection = new SqliteConnection("Data Source=:memory:");
            connection.Open();

            services.AddDbContext<StorefrontDbContext>(options => options.UseSqlite(connection));

            var provider = services.BuildServiceProvider();
            using var scope = provider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<StorefrontDbContext>();
            dbContext.Database.EnsureCreated();
            StorefrontDbSeeder.SeedAsync(dbContext).GetAwaiter().GetResult();
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing)
        {
            connection?.Dispose();
            Environment.SetEnvironmentVariable("AZURE_REGION", null);
        }
    }
}
