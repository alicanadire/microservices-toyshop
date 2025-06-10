using Marten.Schema;

namespace Catalog.API.Data;

public class CatalogInitialData : IInitialData
{
    public async Task Populate(IDocumentStore store, CancellationToken cancellation)
    {
        using var session = store.LightweightSession();

        if (await session.Query<Product>().AnyAsync())
            return;

        // Marten UPSERT will cater for existing records
        session.Store<Product>(GetPreconfiguredProducts());
        await session.SaveChangesAsync();
    }

    private static IEnumerable<Product> GetPreconfiguredProducts() => new List<Product>()
            {
                new Product()
                {
                    Id = new Guid("5334c996-8457-4cf0-815c-ed2b77c4ff61"),
                    Name = "LEGO Creator Expert Evi",
                    Description = "Bu harika LEGO seti çocukların hayal gücünü geliştiren, detaylı bir ev yapım setidir. 1200+ parça ile saatlerce eğlence.",
                    ImageFile = "lego-house.jpg",
                    Price = 89.99M,
                    Category = new List<string> { "Yapı Setleri" }
                },
                new Product()
                {
                    Id = new Guid("c67d6323-e8b1-4bdf-9a75-b0d0d2e7e914"),
                    Name = "Barbie Dreamhouse",
                    Description = "Üç katlı harika Barbie evi, asansör, havuz ve 70'den fazla aksesuar ile. Hayal gücünü sınırsızca geliştirin.",
                    ImageFile = "barbie-dreamhouse.jpg",
                    Price = 199.99M,
                    Category = new List<string> { "Bebekler" }
                },
                new Product()
                {
                    Id = new Guid("4f136e9f-ff8c-4c1f-9a33-d12f689bdab8"),
                    Name = "Hot Wheels Mega Set",
                    Description = "Muhteşem yarış pisti seti ile looplar, rampa ve hız arttırıcılar. 5 adet die-cast araba dahil.",
                    ImageFile = "hotwheels-track.jpg",
                    Price = 45.99M,
                    Category = new List<string> { "Araçlar" }
                },
                new Product()
                {
                    Id = new Guid("6ec1297b-ec0a-4aa1-be25-6726e3b51a27"),
                    Name = "Yumuşacık Ayıcık",
                    Description = "Premium kumaşlardan üretilmiş çok yumuşak peluş ayı. Çocukların en iyi dostu olacak güvenli oyuncak.",
                    ImageFile = "teddy-bear.jpg",
                    Price = 24.99M,
                    Category = new List<string> { "Peluş Oyuncaklar" }
                },
                new Product()
                {
                    Id = new Guid("b786103d-c621-4f5a-b498-23452610f88c"),
                    Name = "Nintendo Switch OLED",
                    Description = "Canlı OLED ekran ile taşınabilir oyun konsolu. Hem evde hem de yolculukta oyun keyfi.",
                    ImageFile = "nintendo-switch.jpg",
                    Price = 299.99M,
                    Category = new List<string> { "Elektronik Oyuncaklar" }
                },
                new Product()
                {
                    Id = new Guid("c4bbc4a2-4555-45d8-97cc-2a99b2167bff"),
                    Name = "Eğitici Tablet",
                    Description = "Çocuklar için özel tasarlanmış eğitici tablet. Oyunlar, hikayeler ve öğretici aktiviteler ile dolu.",
                    ImageFile = "kids-tablet.jpg",
                    Price = 79.99M,
                    Category = new List<string> { "Eğitici Oyuncaklar" }
                },
                new Product()
                {
                    Id = new Guid("93170c85-7795-489c-8e8f-7dcf3b4f4188"),
                    Name = "Sanat ve El Sanatları Seti",
                    Description = "Kapsamlı sanat seti - pastel boya, keçeli kalem, renkli kalemler ve çizim kağıdı. Yaratıcılığı geliştirin.",
                    ImageFile = "art-set.jpg",
                    Price = 34.99M,
                    Category = new List<string> { "Sanat ve El Sanatları" }
                },
                new Product()
                {
                    Id = new Guid("f5a2b3c4-d5e6-4f7a-8b9c-123456789012"),
                    Name = "Uzaktan Kumandalı Drone",
                    Description = "HD kamera ve LED ışıklı kolay uçuş drone. Dış mekan maceraları için mükemmel.",
                    ImageFile = "rc-drone.jpg",
                    Price = 129.99M,
                    Category = new List<string> { "Uzaktan Kumandalı" }
                }
            };

}
