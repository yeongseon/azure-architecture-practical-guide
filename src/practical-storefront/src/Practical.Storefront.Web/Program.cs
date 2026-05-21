using System.Text.Json;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

var explicitConnectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");

builder.Services.AddDbContext<StorefrontDbContext>(options =>
{
    if (!string.IsNullOrWhiteSpace(explicitConnectionString))
    {
        options.UseSqlServer(explicitConnectionString);
        return;
    }

    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=storefront.db");
});

builder.Services
    .AddHealthChecks()
    .AddDbContextCheck<StorefrontDbContext>("database");

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<StorefrontDbContext>();
    await dbContext.Database.EnsureCreatedAsync();
    await StorefrontDbSeeder.SeedAsync(dbContext);
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Index");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.MapHealthChecks("/healthz", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var payload = JsonSerializer.Serialize(new
        {
            status = report.Status == Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Healthy ? "Healthy" : "Unhealthy"
        });

        await context.Response.WriteAsync(payload);
    }
});

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();

public partial class Program;
