using System.ComponentModel.DataAnnotations;

namespace Practical.Storefront.Web.Models;

public class CreateOrderRequest
{
    [Required]
    [StringLength(200)]
    public string CustomerName { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Select a product.")]
    public int ProductId { get; set; }

    [Range(1, 1000)]
    public int Quantity { get; set; } = 1;
}
