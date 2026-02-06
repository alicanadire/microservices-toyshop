namespace Shopping.Web.Pages
{
    public class OrderListModel
        (IOrderingService orderingService, ILogger<OrderListModel> logger)
        : PageModel
    {
        public IEnumerable<OrderModel> Orders { get; set; } = default!;

        public async Task<IActionResult> OnGetAsync()
        {
            logger.LogInformation("Loading orders for user");

            // assumption customerId is passed in from the UI authenticated user swn
            var customerId = new Guid("58c49479-ec65-4de2-86e7-033c546291aa");

            var response = await orderingService.GetOrdersByCustomer(customerId);
            Orders = response.Orders;

            logger.LogInformation($"Successfully loaded {Orders.Count()} orders");
            return Page();
        }
    }
}
