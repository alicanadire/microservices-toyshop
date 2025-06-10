using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Threading.RateLimiting;
using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

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

    // Enhanced logging
    builder.Logging.AddConsole();
    builder.Logging.SetMinimumLevel(LogLevel.Information);

    Log.Information("🔧 Configuring API Gateway services...");

    // YARP Reverse Proxy
    builder.Services.AddReverseProxy()
        .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

    // Enhanced Rate Limiting
    builder.Services.AddRateLimiter(rateLimiterOptions =>
    {
        // Fixed window limiter for general API calls
        rateLimiterOptions.AddFixedWindowLimiter("general", options =>
        {
            options.Window = TimeSpan.FromMinutes(1);
            options.PermitLimit = 100;
            options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            options.QueueLimit = 10;
        });

        // Stricter limiter for auth-required endpoints
        rateLimiterOptions.AddFixedWindowLimiter("authenticated", options =>
        {
            options.Window = TimeSpan.FromMinutes(1);
            options.PermitLimit = 200;
            options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            options.QueueLimit = 20;
        });

        // Very restrictive for ordering (critical operations)
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
                    "http://localhost:5000",      // Shopping Web
                    "http://localhost:6006",      // Identity Server  
                    "http://shopping.web:8080",   // Shopping Web container
                    "http://identity.api:8080"    // Identity container
                  )
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    // JWT Authentication with enhanced configuration
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

            // Enhanced logging for JWT events
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

    // Enhanced Authorization policies
    builder.Services.AddAuthorization(options =>
    {
        // General API access
        options.AddPolicy("ApiScope", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireClaim("scope", "catalog", "basket", "ordering", "shopping");
        });

        // Admin only access
        options.AddPolicy("AdminOnly", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireRole("Admin");
        });

        // Customer access
        options.AddPolicy("CustomerAccess", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireRole("Admin", "Customer");
        });
    });

    // Health checks for downstream services
    builder.Services.AddHealthChecks()
        .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("API Gateway is healthy"))
        .AddUrlGroup(new Uri($"{authority}/health"), "identity-service", timeout: TimeSpan.FromSeconds(10))
        .AddUrlGroup(new Uri("http://catalog.api:8080/health"), "catalog-service", timeout: TimeSpan.FromSeconds(10))
        .AddUrlGroup(new Uri("http://basket.api:8080/health"), "basket-service", timeout: TimeSpan.FromSeconds(10))
        .AddUrlGroup(new Uri("http://ordering.api:8080/health"), "ordering-service", timeout: TimeSpan.FromSeconds(10));

    Log.Information("✅ API Gateway services configured successfully");

    var app = builder.Build();

    Log.Information("🔧 Configuring middleware pipeline...");

    // Configure the HTTP request pipeline
    if (app.Environment.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }

    // Global exception handling
    app.UseExceptionHandler(errorApp =>
    {
        errorApp.Run(async context =>
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "application/json";

            var error = new
            {
                error = "Internal Server Error",
                message = "An unexpected error occurred in the API Gateway",
                timestamp = DateTime.UtcNow,
                path = context.Request.Path
            };

            Log.Error("API Gateway error on path {Path}: {Error}", context.Request.Path, error);
            await context.Response.WriteAsJsonAsync(error);
        });
    });

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
    app.MapHealthChecks("/health", new HealthCheckOptions
    {
        ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    });

    app.MapHealthChecks("/health/ready", new HealthCheckOptions
    {
        Predicate = check => check.Tags.Contains("ready"),
        ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    });

    app.MapHealthChecks("/health/live", new HealthCheckOptions
    {
        Predicate = _ => false,
        ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    });

    // Debug and monitoring endpoints
    app.MapGet("/", () => Results.Ok(new
    {
        service = "API Gateway",
        status = "Running",
        timestamp = DateTime.UtcNow,
        version = "2.0.0",
        environment = app.Environment.EnvironmentName,
        authentication = "JWT Bearer",
        proxy = "YARP"
    })).AllowAnonymous();

    app.MapGet("/debug/routes", () => Results.Ok(new
    {
        routes = new[]
        {
            "/catalog-service/** → Catalog API",
            "/basket-service/** → Basket API (Auth Required)",
            "/ordering-service/** → Ordering API (Auth Required)",
            "/admin/catalog-service/** → Catalog API (Admin Only)"
        }
    })).AllowAnonymous();

    app.MapGet("/debug/policies", () => Results.Ok(new
    {
        rateLimiting = new
        {
            general = "100 requests/minute",
            authenticated = "200 requests/minute",
            ordering = "30 requests/minute"
        }
    })).AllowAnonymous();

    // Map reverse proxy with enhanced configuration
    app.MapReverseProxy(proxyPipeline =>
    {
        proxyPipeline.Use(async (context, next) =>
        {
            // Add correlation ID for request tracking
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
    Log.Information("🔍 Debug routes: http://localhost:6064/debug/routes");

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
