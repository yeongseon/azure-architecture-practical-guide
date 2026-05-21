using System.Net;
using System.Text.RegularExpressions;
using System.Text.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Practical.Storefront.Web.Tests;

public class EndpointsTests(StorefrontApplicationFactory factory) : IClassFixture<StorefrontApplicationFactory>
{
    private readonly HttpClient client = factory.CreateClient();
    private readonly HttpClient noRedirectClient = factory.CreateClient(new WebApplicationFactoryClientOptions
    {
        AllowAutoRedirect = false
    });

    [Fact]
    public async Task Healthz_ReturnsHealthyStatus()
    {
        var response = await client.GetAsync("/healthz");

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        document.RootElement.GetProperty("status").GetString().Should().Be("Healthy");
    }

    [Fact]
    public async Task OpsInfo_ReturnsVersionRegionAndTimestamp()
    {
        var response = await client.GetAsync("/ops/info");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        document.RootElement.GetProperty("version").GetString().Should().Be("1.0.0");
        document.RootElement.GetProperty("region").GetString().Should().Be("test-region");
        DateTimeOffset.TryParse(document.RootElement.GetProperty("timestamp").GetString(), out var timestamp).Should().BeTrue();
        timestamp.Should().NotBe(default);
    }

    [Fact]
    public async Task OpsVersion_ReturnsVersion()
    {
        var response = await client.GetAsync("/ops/version");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        document.RootElement.GetProperty("version").GetString().Should().Be("1.0.0");
    }

    [Fact]
    public async Task HomePage_ReturnsSuccess()
    {
        var response = await client.GetAsync("/");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task OrdersPages_ReturnSuccess()
    {
        var listResponse = await client.GetAsync("/orders");
        var createResponse = await client.GetAsync("/orders/create");

        listResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task CreateOrder_PersistsOrderAndDisplaysMaskedEmail()
    {
        var formResponse = await noRedirectClient.GetAsync("/orders/create");
        var html = await formResponse.Content.ReadAsStringAsync();
        var token = Regex.Match(html, "<input[^>]*name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"", RegexOptions.IgnoreCase).Groups[1].Value;

        token.Should().NotBeNullOrWhiteSpace();

        var postResponse = await noRedirectClient.PostAsync("/orders/create", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["__RequestVerificationToken"] = token,
            ["CustomerName"] = "Taylor Architect",
            ["CustomerEmail"] = "taylor@example.com",
            ["ProductId"] = "1",
            ["Quantity"] = "2"
        }));

        postResponse.StatusCode.Should().Be(HttpStatusCode.Redirect);
        postResponse.Headers.Location?.OriginalString.Should().Be("/orders");

        var ordersResponse = await client.GetAsync("/orders");
        var ordersHtml = await ordersResponse.Content.ReadAsStringAsync();

        ordersResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        ordersHtml.Should().Contain("Order #");
        ordersHtml.Should().Contain("Taylor Architect");
        ordersHtml.Should().Contain("t***@example.com");
        ordersHtml.Should().Contain("Azure Architecture Book × 2");
    }
}
