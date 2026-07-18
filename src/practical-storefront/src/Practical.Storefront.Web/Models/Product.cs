using System.ComponentModel.DataAnnotations;

namespace Practical.Storefront.Web.Models;

public class Product
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;

    [Range(0, 1000000)]
    public decimal Price { get; set; }
}
