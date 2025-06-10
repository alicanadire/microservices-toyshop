using Identity.API.Configuration;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

Log.Information("🔑 Starting Identity Service - MUST WORK!");

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Ensure we listen on all interfaces
    builder.WebHost.UseUrls("http://+:8080");

    builder.Host.UseSerilog((context, configuration) =>
        configuration.ReadFrom.Configuration(context.Configuration));

    // Add services to the container.
    builder.Services.AddDbContext<IdentityDbContext>(options =>
        options.UseInMemoryDatabase("IdentityDb"));

    builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
    {
        // Password settings
        options.Password.RequireDigit = true;
        options.Password.RequiredLength = 6;
        options.Password.RequireNonAlphanumeric = false;
        options.Password.RequireUppercase = false;
        options.Password.RequireLowercase = false;

        // User settings
        options.User.RequireUniqueEmail = true;
        options.SignIn.RequireConfirmedEmail = false;
    })
    .AddEntityFrameworkStores<IdentityDbContext>()
    .AddDefaultTokenProviders();

    builder.Services.AddIdentityServer(options =>
    {
        options.Events.RaiseErrorEvents = true;
        options.Events.RaiseInformationEvents = true;
        options.Events.RaiseFailureEvents = true;
        options.Events.RaiseSuccessEvents = true;
        options.EmitStaticAudienceClaim = true;
        // Use environment variable or default to localhost
        options.IssuerUri = builder.Configuration["IdentityServer:IssuerUri"] ?? "http://localhost:5000";
    })
    .AddInMemoryIdentityResources(IdentityServerConfig.IdentityResources)
    .AddInMemoryApiScopes(IdentityServerConfig.ApiScopes)
    .AddInMemoryApiResources(IdentityServerConfig.ApiResources)
    .AddInMemoryClients(IdentityServerConfig.Clients)
    .AddAspNetIdentity<ApplicationUser>()
    .AddProfileService<ProfileService>()
    .AddDeveloperSigningCredential();

    builder.Services.AddTransient<IProfileService, ProfileService>();

    // CORS for Shopping Web and Gateway
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.WithOrigins(
                    "http://localhost:6005",    // Shopping.Web
                    "http://localhost:6004",    // API Gateway
                    "http://shopping.web:8080", // Shopping.Web container
                    "http://yarpapigateway:8080" // API Gateway container
                  )
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    var app = builder.Build();

    // Initialize database
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

        await SeedDataAsync(context, userManager, roleManager);
    }

    // Configure the HTTP request pipeline.
    // Remove HTTPS redirection for HTTP-only setup

    app.UseCors("AllowAll");
    app.UseRouting();
    app.UseIdentityServer();
    app.UseAuthorization();

    // Health check and debug endpoints
    app.MapGet("/", () => Results.Ok(new {
        service = "Identity Service API",
        status = "Running",
        timestamp = DateTime.UtcNow,
        version = "2.0.0-fixed",
        issuer = app.Configuration["IdentityServer:IssuerUri"]
    }));

    app.MapGet("/health", () => Results.Ok(new {
        status = "Healthy",
        timestamp = DateTime.UtcNow
    }));

    app.MapGet("/debug/config", () => Results.Ok(new {
        Authority = app.Configuration["IdentityServer:IssuerUri"],
        Environment = app.Environment.EnvironmentName,
        ConnectionString = app.Configuration.GetConnectionString("Database")?.Substring(0, 50) + "...",
        Clients = IdentityServerConfig.Clients.Select(c => new { c.ClientId, c.ClientName }).ToList()
    }));

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Identity Service terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

static async Task SeedDataAsync(IdentityDbContext context, UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager)
{
    await context.Database.EnsureCreatedAsync();

    // Create roles
    if (!await roleManager.RoleExistsAsync("Admin"))
    {
        await roleManager.CreateAsync(new IdentityRole("Admin"));
    }

    if (!await roleManager.RoleExistsAsync("Customer"))
    {
        await roleManager.CreateAsync(new IdentityRole("Customer"));
    }

    // Create admin user
    var adminEmail = "admin@eshop.com";
    var adminUser = await userManager.FindByEmailAsync(adminEmail);

    if (adminUser == null)
    {
        adminUser = new ApplicationUser
        {
            UserName = adminEmail,
            Email = adminEmail,
            FirstName = "Admin",
            LastName = "User",
            EmailConfirmed = true,
            IsActive = true
        };

        await userManager.CreateAsync(adminUser, "Password123!");
        await userManager.AddToRoleAsync(adminUser, "Admin");
    }

    // Create test customer
    var customerEmail = "customer@eshop.com";
    var customerUser = await userManager.FindByEmailAsync(customerEmail);

    if (customerUser == null)
    {
        customerUser = new ApplicationUser
        {
            UserName = customerEmail,
            Email = customerEmail,
            FirstName = "Test",
            LastName = "Customer",
            EmailConfirmed = true,
            IsActive = true
        };

        await userManager.CreateAsync(customerUser, "Password123!");
        await userManager.AddToRoleAsync(customerUser, "Customer");
    }
}
