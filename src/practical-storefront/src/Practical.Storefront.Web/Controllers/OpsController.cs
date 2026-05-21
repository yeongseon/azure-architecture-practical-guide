using Microsoft.AspNetCore.Mvc;

namespace Practical.Storefront.Web.Controllers;

[ApiController]
public class OpsController : ControllerBase
{
    private const string Version = "1.0.0";

    [HttpGet("ops/info")]
    public IActionResult GetInfo()
    {
        return Ok(new
        {
            version = Version,
            region = Environment.GetEnvironmentVariable("AZURE_REGION") ?? "local",
            timestamp = DateTime.UtcNow.ToString("O")
        });
    }

    [HttpGet("ops/version")]
    public IActionResult GetVersion()
    {
        return Ok(new { version = Version });
    }
}
