// This file is no longer needed as we're using MongoDB
// Left for reference only - Identity is now handled by MongoDB via AspNetCore.Identity.MongoDbCore

using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Identity.API.Data;

/// <summary>
/// Legacy Entity Framework Identity Context - Not used with MongoDB implementation
/// MongoDB identity is handled automatically by AspNetCore.Identity.MongoDbCore
/// </summary>
[Obsolete("This context is not used when using MongoDB. Identity is handled by AspNetCore.Identity.MongoDbCore")]
public class IdentityDbContext : IdentityDbContext<ApplicationUser>
{
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Customize table names if needed
        builder.Entity<ApplicationUser>(entity =>
        {
            entity.ToTable("Users");
        });
    }
}
