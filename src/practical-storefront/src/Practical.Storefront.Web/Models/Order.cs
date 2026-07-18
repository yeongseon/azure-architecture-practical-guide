using System.ComponentModel.DataAnnotations;

namespace Practical.Storefront.Web.Models;

public class Order
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string CustomerName { get; set; } = string.Empty;

    public int ProductId { get; set; }

    public Product? Product { get; set; }

    [Range(1, 1000)]
    public int Quantity { get; set; } = 1;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
