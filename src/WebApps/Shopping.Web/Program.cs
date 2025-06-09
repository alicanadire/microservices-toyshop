using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using System.IdentityModel.Tokens.Jwt;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages(options =>
{
    options.Conventions.AuthorizePage("/Cart");
    options.Conventions.AuthorizePage("/Checkout");
    options.Conventions.AuthorizePage("/OrderList");
});

// Clear default claims mapping
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

// Authentication
var identityServerSettings = builder.Configuration.GetSection("IdentityServerSettings");
builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
})
.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
{
    options.AccessDeniedPath = "/Account/AccessDenied";
})
.AddOpenIdConnect(OpenIdConnectDefaults.AuthenticationScheme, options =>
{
    options.Authority = identityServerSettings["Authority"];
    options.ClientId = identityServerSettings["ClientId"];
    options.ClientSecret = identityServerSettings["ClientSecret"];
    options.ResponseType = "code";
    options.SaveTokens = true;
    options.GetClaimsFromUserInfoEndpoint = true;
    options.RequireHttpsMetadata = bool.Parse(identityServerSettings["RequireHttpsMetadata"] ?? "true");

    options.Scope.Clear();
    var scopes = identityServerSettings["Scope"]?.Split(' ') ?? Array.Empty<string>();
    foreach (var scope in scopes)
    {
        options.Scope.Add(scope);
    }

    options.ClaimActions.MapJsonKey("role", "role", "role");
    options.TokenValidationParameters.NameClaimType = "name";
    options.TokenValidationParameters.RoleClaimType = "role";
});

builder.Services.AddAuthorization();

// HTTP Client with JWT Token
builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<AuthenticationDelegatingHandler>();

builder.Services.AddRefitClient<ICatalogService>()
    .ConfigureHttpClient(c =>
    {
        c.BaseAddress = new Uri(builder.Configuration["ApiSettings:GatewayAddress"]!);
    })
    .AddHttpMessageHandler<AuthenticationDelegatingHandler>();

builder.Services.AddRefitClient<IBasketService>()
    .ConfigureHttpClient(c =>
    {
        c.BaseAddress = new Uri(builder.Configuration["ApiSettings:GatewayAddress"]!);
    })
    .AddHttpMessageHandler<AuthenticationDelegatingHandler>();

builder.Services.AddRefitClient<IOrderingService>()
    .ConfigureHttpClient(c =>
    {
        c.BaseAddress = new Uri(builder.Configuration["ApiSettings:GatewayAddress"]!);
    })
    .AddHttpMessageHandler<AuthenticationDelegatingHandler>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages();

app.Run();
