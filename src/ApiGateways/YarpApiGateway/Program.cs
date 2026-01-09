using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Threading.RateLimiting;

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

Log.Information("🚪 Starting API Gateway - EShop Microservices");

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog((context, configuration) =>
        configuration.ReadFrom.Configuration(context.Configuration));

    Log.Information("🔧 Configuring API Gateway services...");

    // YARP Reverse Proxy
    builder.Services.AddReverseProxy()
        .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

    // Enhanced Rate Limiting
    builder.Services.AddRateLimiter(rateLimiterOptions =>
    {
        rateLimiterOptions.AddFixedWindowLimiter("general", options =>
        {
            options.Window = TimeSpan.FromMinutes(1);
            options.PermitLimit = 100;
            options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            options.QueueLimit = 10;
        });

        rateLimiterOptions.AddFixedWindowLimiter("authenticated", options =>
        {
            options.Window = TimeSpan.FromMinutes(1);
            options.PermitLimit = 200;
            options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            options.QueueLimit = 20;
        });

        rateLimiterOptions.AddFixedWindowLimiter("ordering", options =>
        {
            options.Window = TimeSpan.FromMinutes(1);
            options.PermitLimit = 30;
            options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            options.QueueLimit = 5;
        });

        rateLimiterOptions.RejectionStatusCode = 429;
    });

    // CORS for web clients
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowWebClients", policy =>
        {
            policy.WithOrigins(
                    "http://localhost:5000",
                    "http://localhost:6006",
                    "http://shopping.web:8080",
                    "http://identity.api:8080"
                  )
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    // JWT Authentication
    var identityServerSettings = builder.Configuration.GetSection("IdentityServerSettings");
    var authority = identityServerSettings["Authority"];

    Log.Information("🔑 Configuring JWT Authentication with Authority: {Authority}", authority);

    builder.Services.AddAuthentication("Bearer")
        .AddJwtBearer("Bearer", options =>
        {
            options.Authority = authority;
            options.RequireHttpsMetadata = bool.Parse(identityServerSettings["RequireHttpsMetadata"] ?? "false");
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = true,
                ValidAudiences = new[] { "catalog", "basket", "ordering", "shopping", "gateway" },
                ValidateIssuer = true,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(5),
                NameClaimType = "name",
                RoleClaimType = "role"
            };

            options.Events = new Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerEvents
            {
                OnAuthenticationFailed = context =>
                {
                    Log.Warning("JWT Authentication failed: {Exception}", context.Exception.Message);
                    return Task.CompletedTask;
                },
                OnTokenValidated = context =>
                {
                    Log.Debug("JWT Token validated for user: {User}", context.Principal?.Identity?.Name);
                    return Task.CompletedTask;
                }
            };
        });

    // Authorization policies
    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("AdminOnly", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireRole("Admin");
        });

        options.AddPolicy("CustomerAccess", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireRole("Admin", "Customer");
        });
    });

    // Basic Health checks
    builder.Services.AddHealthChecks()
        .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("API Gateway is healthy"));

    Log.Information("✅ API Gateway services configured successfully");

    var app = builder.Build();

    Log.Information("🔧 Configuring middleware pipeline...");

    if (app.Environment.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }

    // Security headers
    app.Use(async (context, next) =>
    {
        context.Response.Headers["X-Content-Type-Options"] = "nosniff";
        context.Response.Headers["X-Frame-Options"] = "DENY";
        context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
        context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
        await next();
    });

    app.UseCors("AllowWebClients");
    app.UseAuthentication();
    app.UseAuthorization();
    app.UseRateLimiter();

    // Health check endpoints
    app.MapHealthChecks("/health");

    // Debug endpoints
    app.MapGet("/", () => Results.Ok(new
    {
        service = "API Gateway",
        status = "Running",
        timestamp = DateTime.UtcNow,
        version = "2.0.0-fixed",
        environment = app.Environment.EnvironmentName
    }));

    app.MapGet("/debug/routes", () => Results.Ok(new
    {
        routes = new[]
        {
            "/catalog-service/** → Catalog API",
            "/basket-service/** → Basket API (Auth Required)",
            "/ordering-service/** → Ordering API (Auth Required)"
        }
    }));

    // Map reverse proxy
    app.MapReverseProxy(proxyPipeline =>
    {
        proxyPipeline.Use(async (context, next) =>
        {
            var correlationId = Guid.NewGuid().ToString();
            context.Response.Headers["X-Correlation-ID"] = correlationId;

            Log.Debug("🔄 Proxy request {CorrelationId}: {Method} {Path}",
                correlationId, context.Request.Method, context.Request.Path);

            await next();

            Log.Debug("✅ Proxy response {CorrelationId}: {StatusCode}",
                correlationId, context.Response.StatusCode);
        });
    });

    Log.Information("🚀 API Gateway starting...");
    Log.Information("🌐 Available at: http://localhost:6064");
    Log.Information("🏥 Health check: http://localhost:6064/health");

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "API Gateway terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
