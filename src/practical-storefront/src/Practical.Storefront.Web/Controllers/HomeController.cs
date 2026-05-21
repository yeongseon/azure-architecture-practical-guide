using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Data;

namespace Practical.Storefront.Web.Controllers;

public class HomeController(StorefrontDbContext dbContext) : Controller
{
    [HttpGet("/")]
    public async Task<IActionResult> Index()
    {
        var products = await dbContext.Products
            .AsNoTracking()
            .Where(product => product.IsAvailable)
            .OrderBy(product => product.Name)
            .ToListAsync();

        return View(products);
    }
}
