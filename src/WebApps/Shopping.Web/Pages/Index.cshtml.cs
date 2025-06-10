using Refit;

namespace Shopping.Web.Pages;

public class IndexModel(ICatalogService catalogService, IBasketService basketService, ILogger<IndexModel> logger) : PageModel
{
    public IEnumerable<ProductModel> ProductList { get; set; } = new List<ProductModel>();
    public bool IsDataLoaded { get; set; } = false;
    public string ErrorMessage { get; set; } = string.Empty;

    public async Task<IActionResult> OnGetAsync()
    {
        logger.LogInformation("Index page visited");

        // Check if user is authenticated first
        if (!User.Identity?.IsAuthenticated ?? true)
        {
            logger.LogInformation("Anonymous user accessing index page - showing sample products");
            ProductList = GetSampleProducts();
            IsDataLoaded = false;
            ErrorMessage = "Please log in to see our full product catalog";
            return Page();
        }

        try
        {
            var result = await catalogService.GetProducts();
            ProductList = result.Products ?? new List<ProductModel>();
            IsDataLoaded = true;
            logger.LogInformation($"Successfully loaded {ProductList.Count()} products for authenticated user");
        }
        catch (ApiException ex) when (ex.StatusCode == System.Net.HttpStatusCode.Unauthorized)
        {
            // Token might be expired or invalid - show sample products
            logger.LogWarning("Unauthorized access to catalog service - token might be expired");
            ProductList = GetSampleProducts();
            IsDataLoaded = false;
            ErrorMessage = "Your session may have expired. Please log in again to see our full product catalog";
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error loading products on index page");
            ProductList = GetSampleProducts();
            IsDataLoaded = false;
            ErrorMessage = "Unable to load products at this time. Please try again later";
        }

        return Page();
    }

    public async Task<IActionResult> OnPostAddToCartAsync(Guid productId)
    {
        logger.LogInformation("Add to cart button clicked");

        try
        {
            var productResponse = await catalogService.GetProduct(productId);

            var basket = await basketService.LoadUserBasket();

            basket.Items.Add(new ShoppingCartItemModel
            {
                ProductId = productId,
                ProductName = productResponse.Product.Name,
                Price = productResponse.Product.Price,
                Quantity = 1,
                Color = "Black"
            });

            await basketService.StoreBasket(new StoreBasketRequest(basket));

            return RedirectToPage("Cart");
        }
        catch (ApiException ex) when (ex.StatusCode == System.Net.HttpStatusCode.Unauthorized)
        {
            // User not authenticated, redirect to login
            return RedirectToPage("/Account/Login");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error adding product to cart");
            return Page();
        }
    }

    private List<ProductModel> GetSampleProducts()
    {
        return new List<ProductModel>
        {
            new ProductModel
            {
                Id = Guid.NewGuid(),
                Name = "Welcome to EShop!",
                Description = "Sign in to see our full product catalog with amazing products",
                ImageFile = "sample-product.jpg",
                Price = 0,
                Category = new List<string> { "Welcome" }
            },
            new ProductModel
            {
                Id = Guid.NewGuid(),
                Name = "Premium Electronics",
                Description = "Discover our premium electronics collection",
                ImageFile = "electronics.jpg",
                Price = 0,
                Category = new List<string> { "Electronics" }
            },
            new ProductModel
            {
                Id = Guid.NewGuid(),
                Name = "Fashion & Style",
                Description = "Browse our latest fashion trends",
                ImageFile = "fashion.jpg",
                Price = 0,
                Category = new List<string> { "Fashion" }
            },
            new ProductModel
            {
                Id = Guid.NewGuid(),
                Name = "Home & Garden",
                Description = "Everything for your home and garden",
                ImageFile = "home.jpg",
                Price = 0,
                Category = new List<string> { "Home" }
            }
        };
    }
}
