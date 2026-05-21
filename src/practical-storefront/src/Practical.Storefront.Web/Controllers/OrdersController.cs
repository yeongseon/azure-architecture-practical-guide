using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Practical.Storefront.Web.Data;
using Practical.Storefront.Web.Models;

namespace Practical.Storefront.Web.Controllers;

public class OrdersController(StorefrontDbContext dbContext) : Controller
{
    [HttpGet("orders")]
    public async Task<IActionResult> Index()
    {
        var orders = await dbContext.Orders
            .AsNoTracking()
            .Include(order => order.Items)
            .OrderByDescending(order => order.CreatedAt)
            .Take(10)
            .ToListAsync();

        return View(orders);
    }

    [HttpGet("orders/create")]
    public async Task<IActionResult> Create(int? productId)
    {
        var products = await GetAvailableProductsAsync();
        ViewBag.ProductOptions = new SelectList(products, nameof(Product.Id), nameof(Product.Name), productId);

        var model = new OrderFormViewModel
        {
            ProductId = productId ?? products.FirstOrDefault()?.Id ?? 0,
            AvailableProducts = products
        };

        return View(model);
    }

    [HttpPost("orders/create")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(OrderFormViewModel model)
    {
        model.AvailableProducts = await GetAvailableProductsAsync();
        ViewBag.ProductOptions = new SelectList(model.AvailableProducts, nameof(Product.Id), nameof(Product.Name), model.ProductId);

        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var product = await dbContext.Products.FirstOrDefaultAsync(item => item.Id == model.ProductId && item.IsAvailable);
        if (product is null)
        {
            ModelState.AddModelError(nameof(model.ProductId), "Select an available product.");
            return View(model);
        }

        var orderItem = new OrderItem
        {
            ProductId = product.Id,
            ProductName = product.Name,
            Quantity = model.Quantity,
            UnitPrice = product.Price
        };

        var order = new Order
        {
            CustomerName = model.CustomerName,
            CustomerEmail = model.CustomerEmail,
            CreatedAt = DateTime.UtcNow,
            TotalAmount = orderItem.UnitPrice * orderItem.Quantity,
            Items = [orderItem]
        };

        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync();

        TempData["OrderMessage"] = $"Order #{order.Id} created successfully.";
        return RedirectToAction(nameof(Index));
    }

    private async Task<IReadOnlyList<Product>> GetAvailableProductsAsync()
    {
        return await dbContext.Products
            .AsNoTracking()
            .Where(product => product.IsAvailable)
            .OrderBy(product => product.Name)
            .ToListAsync();
    }
}
