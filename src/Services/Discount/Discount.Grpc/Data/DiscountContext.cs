using Microsoft.EntityFrameworkCore;
using Discount.Grpc.Models;

namespace Discount.Grpc.Data;

public class DiscountContext : DbContext
{
    public DbSet<Coupon> Coupons { get; set; } = default!;

    public DiscountContext(DbContextOptions<DiscountContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Coupon>().HasData(
            new Coupon { Id = 1, ProductName = "LEGO Creator Expert Evi", Description = "LEGO Oyuncakları İndirimi", Amount = 20 },
            new Coupon { Id = 2, ProductName = "Barbie Dreamhouse", Description = "Barbie Bebek İndirimi", Amount = 30 },
            new Coupon { Id = 3, ProductName = "Hot Wheels Mega Set", Description = "Hot Wheels Araç İndirimi", Amount = 10 },
            new Coupon { Id = 4, ProductName = "Nintendo Switch OLED", Description = "Gaming Konsol İndirimi", Amount = 50 },
            new Coupon { Id = 5, ProductName = "Eğitici Tablet", Description = "Eğitici Oyuncak İndirimi", Amount = 15 }
        );
    }
}
