using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace Ordering.Infrastructure.Data.Extensions;

public static class InitialData
{
    public static IEnumerable<Customer> Customers =>
        new List<Customer>
        {
            Customer.Create(CustomerId.Of(new Guid("58c49479-ec65-4de2-86e7-033c546291aa")), "Ahmet", "info@toyshop.com"),
            Customer.Create(CustomerId.Of(new Guid("189dc8dc-990f-48e0-a37b-e6f2b60b9d7d")), "Ayşe", "ayse@toyshop.com")
        };

    public static IEnumerable<Product> Products =>
        new List<Product>
        {
            Product.Create(ProductId.Of(new Guid("5334c996-8457-4cf0-815c-ed2b77c4ff61")), "LEGO Creator Expert Evi", 89.99M),
            Product.Create(ProductId.Of(new Guid("c67d6323-e8b1-4bdf-9a75-b0d0d2e7e914")), "Barbie Dreamhouse", 199.99M),
            Product.Create(ProductId.Of(new Guid("4f136e9f-ff8c-4c1f-9a33-d12f689bdab8")), "Hot Wheels Mega Set", 45.99M),
            Product.Create(ProductId.Of(new Guid("6ec1297b-ec0a-4aa1-be25-6726e3b51a27")), "Yumuşacık Ayıcık", 24.99M),
            Product.Create(ProductId.Of(new Guid("b786103d-c621-4f5a-b498-23452610f88c")), "Nintendo Switch OLED", 299.99M),
            Product.Create(ProductId.Of(new Guid("c4bbc4a2-4555-45d8-97cc-2a99b2167bff")), "Eğitici Tablet", 79.99M),
            Product.Create(ProductId.Of(new Guid("93170c85-7795-489c-8e8f-7dcf3b4f4188")), "Sanat ve El Sanatları Seti", 34.99M),
            Product.Create(ProductId.Of(new Guid("f5a2b3c4-d5e6-4f7a-8b9c-123456789012")), "Uzaktan Kumandalı Drone", 129.99M)
        };

    public static IEnumerable<Order> OrdersWithItems
    {
        get
        {
            var address = Address.Of("Ahmet", "Demir", "info@toyshop.com", "Çocuk Sokak 123", "Türkiye", "İstanbul", "34000");
            var payment = Payment.Of("Ahmet", "4111111111111111", "12/28", "123", 1);

            var order1 = Order.Create(
                    OrderId.Of(Guid.NewGuid()),
                    CustomerId.Of(new Guid("58c49479-ec65-4de2-86e7-033c546291aa")),
                    OrderName.Of("ORD_1"),
                    shippingAddress: address,
                    billingAddress: address,
                    payment);

            order1.Add(ProductId.Of(new Guid("5334c996-8457-4cf0-815c-ed2b77c4ff61")), 2, 89.99M);
            order1.Add(ProductId.Of(new Guid("c67d6323-e8b1-4bdf-9a75-b0d0d2e7e914")), 1, 199.99M);

            var order2 = Order.Create(
                    OrderId.Of(Guid.NewGuid()),
                    CustomerId.Of(new Guid("189dc8dc-990f-48e0-a37b-e6f2b60b9d7d")),
                    OrderName.Of("ORD_2"),
                    shippingAddress: address,
                    billingAddress: address,
                    payment);

            order2.Add(ProductId.Of(new Guid("4f136e9f-ff8c-4c1f-9a33-d12f689bdab8")), 1, 45.99M);
            order2.Add(ProductId.Of(new Guid("6ec1297b-ec0a-4aa1-be25-6726e3b51a27")), 2, 24.99M);

            return new List<Order> { order1, order2 };
        }
    }

    // Legacy method for backward compatibility
    public static async Task SeedAsync(IApplicationBuilder app)
    {
        using var scope = app.ApplicationServices.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        if (!await context.Customers.AnyAsync())
        {
            await context.Customers.AddRangeAsync(Customers);
        }

        if (!await context.Products.AnyAsync())
        {
            await context.Products.AddRangeAsync(Products);
        }

        if (!await context.Orders.AnyAsync())
        {
            await context.Orders.AddRangeAsync(OrdersWithItems);
        }

        await context.SaveChangesAsync();
    }
}
