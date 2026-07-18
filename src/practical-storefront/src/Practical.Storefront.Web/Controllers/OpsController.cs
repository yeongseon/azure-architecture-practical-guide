using System.Reflection;
using Microsoft.AspNetCore.Mvc;

namespace Practical.Storefront.Web.Controllers;

[ApiController]
[Route("ops")]
public class OpsController : ControllerBase
{
    private static string Version =>
        Environment.GetEnvironmentVariable("APP_VERSION")
        ?? Assembly.GetExecutingAssembly()
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion
        ?? Assembly.GetExecutingAssembly().GetName().Version?.ToString()
        ?? "0.0.0";

    private static string Region =>
        Environment.GetEnvironmentVariable("REGION") ?? "local";

    [HttpGet("info")]
    public IActionResult Info() => Ok(new { version = Version, region = Region });

    [HttpGet("version")]
    public IActionResult GetVersion() => Ok(new { version = Version });
}
