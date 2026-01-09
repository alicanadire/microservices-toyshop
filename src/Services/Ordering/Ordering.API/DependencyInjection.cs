using BuildingBlocks.Exceptions.Handler;
using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Ordering.API;

public static class DependencyInjection
{
    public static IServiceCollection AddApiServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddCarter();

        services.AddExceptionHandler<CustomExceptionHandler>();

        // JWT Authentication
        var identityServerSettings = configuration.GetSection("IdentityServerSettings");
        services.AddAuthentication("Bearer")
            .AddJwtBearer("Bearer", options =>
            {
                options.Authority = identityServerSettings["Authority"];
                options.RequireHttpsMetadata = bool.Parse(identityServerSettings["RequireHttpsMetadata"] ?? "false");
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateAudience = true,
                    ValidAudiences = new[] { "ordering", "shopping" },
                    ValidateIssuer = true,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromMinutes(5),
                    NameClaimType = "name",
                    RoleClaimType = "role"
                };
            });

        services.AddAuthorization();

        services.AddHealthChecks()
            .AddSqlServer(configuration.GetConnectionString("Database")!);

        return services;
    }

    public static WebApplication UseApiServices(this WebApplication app)
    {
        app.UseExceptionHandler(options => { });

        app.UseAuthentication();
        app.UseAuthorization();

        app.MapCarter();

        app.UseHealthChecks("/health",
            new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
            });

        return app;
    }
}
