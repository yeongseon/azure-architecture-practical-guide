using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Data;
using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Controllers;

public class HomeController : Controller
{
    private readonly StorefrontDbContext _db;

    public HomeController(StorefrontDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index()
    {
        var products = await _db.Products.OrderBy(p => p.Name).ToListAsync();
        return View(products);
    }

    public async Task<IActionResult> Orders()
    {
        var orders = await _db.Orders
            .Include(o => o.Product)
            .OrderByDescending(o => o.CreatedAt)
            .Take(20)
            .ToListAsync();
        return View(orders);
    }

    [HttpGet]
    public async Task<IActionResult> Create()
    {
        ViewBag.Products = await _db.Products.OrderBy(p => p.Name).ToListAsync();
        return View(new Order());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Order order)
    {
        var productExists = await _db.Products.AnyAsync(p => p.Id == order.ProductId);
        if (!productExists)
        {
            ModelState.AddModelError(nameof(order.ProductId), "Selected product does not exist.");
        }

        if (!ModelState.IsValid)
        {
            ViewBag.Products = await _db.Products.OrderBy(p => p.Name).ToListAsync();
            return View(order);
        }

        order.CreatedAt = DateTime.UtcNow;
        _db.Orders.Add(order);
        await _db.SaveChangesAsync();
        return RedirectToAction(nameof(Orders));
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
