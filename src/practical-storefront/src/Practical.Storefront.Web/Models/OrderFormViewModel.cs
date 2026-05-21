using System.ComponentModel.DataAnnotations;

namespace Practical.Storefront.Web.Models;

public class OrderFormViewModel
{
    [Required]
    [StringLength(120)]
    [Display(Name = "Customer name")]
    public string CustomerName { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(200)]
    [Display(Name = "Customer email")]
    public string CustomerEmail { get; set; } = string.Empty;

    [Range(1, int.MaxValue)]
    [Display(Name = "Product")]
    public int ProductId { get; set; }

    [Range(1, 20)]
    public int Quantity { get; set; } = 1;

    public IReadOnlyList<Product> AvailableProducts { get; set; } = [];
}
