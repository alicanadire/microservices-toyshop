using Identity.API.Configuration;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

Log.Information("🔑 Starting Identity Service - Stable Version!");

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Ensure we listen on all interfaces
    builder.WebHost.UseUrls("http://+:8080");
    
    // Enhanced logging for debugging
    builder.Logging.ClearProviders();
    builder.Logging.AddConsole();
    builder.Logging.SetMinimumLevel(LogLevel.Debug);
    
    Log.Information("✅ WebHost configured successfully");
    Log.Information("🌐 Listening on: http://+:8080");
    Log.Information("🔧 Environment: {Environment}", builder.Environment.EnvironmentName);

    builder.Host.UseSerilog((context, configuration) =>
        configuration.ReadFrom.Configuration(context.Configuration));

    // Add services to the container
    Log.Information("🔧 Configuring services...");
    
    // Use in-memory database for reliability and speed
    builder.Services.AddDbContext<IdentityDbContext>(options =>
    {
        Log.Information("💾 Using in-memory database for development");
        options.UseInMemoryDatabase("IdentityDb");
    });
    
    Log.Information("✅ Database context configured");

    // Configure Identity
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

    Log.Information("✅ Identity configured");

    // Configure IdentityServer
    builder.Services.AddIdentityServer(options =>
    {
        options.Events.RaiseErrorEvents = true;
        options.Events.RaiseInformationEvents = true;
        options.Events.RaiseFailureEvents = true;
        options.Events.RaiseSuccessEvents = true;
        options.EmitStaticAudienceClaim = true;
        options.IssuerUri = builder.Configuration["IdentityServer:IssuerUri"] ?? "http://localhost:6006";
    })
    .AddInMemoryIdentityResources(IdentityServerConfig.IdentityResources)
    .AddInMemoryApiScopes(IdentityServerConfig.ApiScopes)
    .AddInMemoryApiResources(IdentityServerConfig.ApiResources)
    .AddInMemoryClients(IdentityServerConfig.Clients)
    .AddAspNetIdentity<ApplicationUser>()
    .AddProfileService<ProfileService>()
    .AddDeveloperSigningCredential();

    builder.Services.AddTransient<IProfileService, ProfileService>();

    Log.Information("✅ IdentityServer configured");

    // CORS for all clients
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.WithOrigins(
                    "http://localhost:5000",    // Shopping.Web
                    "http://localhost:6064",    // API Gateway
                    "http://shopping.web:8080", // Shopping.Web container
                    "http://yarpapigateway:8080" // API Gateway container
                  )
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    Log.Information("✅ CORS configured");

    Log.Information("🏗️ Building application...");
    var app = builder.Build();
    Log.Information("✅ Application built successfully");

    // Initialize database with seed data
    Log.Information("🌱 Seeding database...");
    try
    {
        using (var scope = app.Services.CreateScope())
        {
            var context = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
            var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

            await SeedDataAsync(context, userManager, roleManager);
            Log.Information("✅ Database seeded successfully");
        }
    }
    catch (Exception ex)
    {
        Log.Warning(ex, "⚠️ Database seeding failed, but continuing...");
    }

    Log.Information("🔧 Configuring middleware pipeline...");
    
    // Configure the HTTP request pipeline
    if (app.Environment.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }

    app.UseCors("AllowAll");
    app.UseRouting();
    app.UseIdentityServer();
    app.UseAuthorization();

    Log.Information("🌐 Configuring endpoints...");
    
    // Health check and debug endpoints
    app.MapGet("/", () => {
        Log.Information("📡 Root endpoint called");
        return Results.Ok(new { 
            service = "Identity Service API", 
            status = "Running with In-Memory Database", 
            timestamp = DateTime.UtcNow,
            version = "3.0.0-stable",
            issuer = app.Configuration["IdentityServer:IssuerUri"],
            environment = app.Environment.EnvironmentName,
            database = "In-Memory"
        });
    });
    
    app.MapGet("/health", () => {
        Log.Information("🏥 Health check endpoint called");
        return Results.Ok(new { 
            status = "Healthy", 
            timestamp = DateTime.UtcNow,
            database = "In-Memory",
            uptime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss")
        });
    });
    
    app.MapGet("/debug/config", () => {
        Log.Information("🔍 Debug config endpoint called");
        return Results.Ok(new {
            Authority = app.Configuration["IdentityServer:IssuerUri"],
            Environment = app.Environment.EnvironmentName,
            Database = "In-Memory",
            Clients = IdentityServerConfig.Clients.Select(c => new { c.ClientId, c.ClientName }).ToList(),
            Configuration = new {
                Urls = app.Configuration["ASPNETCORE_URLS"],
                HttpPorts = app.Configuration["ASPNETCORE_HTTP_PORTS"]
            }
        });
    });

    app.MapGet("/debug/users", async (UserManager<ApplicationUser> userManager) => {
        var users = userManager.Users.Select(u => new { 
            u.Email, 
            u.UserName, 
            u.FirstName, 
            u.LastName,
            u.IsActive 
        }).ToList();
        return Results.Ok(new { Users = users, Count = users.Count });
    });

    Log.Information("🚀 Starting Identity Server...");
    Log.Information("🌐 Identity Server will be available at: http://localhost:6006");
    Log.Information("🏥 Health check: http://localhost:6006/health");
    Log.Information("🔍 Debug info: http://localhost:6006/debug/config");
    Log.Information("👥 Users info: http://localhost:6006/debug/users");
    
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
