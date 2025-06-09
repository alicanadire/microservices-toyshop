using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Shopping.Web.Models.Identity;
using System.Security.Claims;

namespace Shopping.Web.Pages.Account;

[Authorize]
public class ProfileModel : PageModel
{
    public UserViewModel User { get; set; } = default!;

    public void OnGet()
    {
        User = new UserViewModel
        {
            Id = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty,
            FirstName = HttpContext.User.FindFirst("given_name")?.Value ?? string.Empty,
            LastName = HttpContext.User.FindFirst("family_name")?.Value ?? string.Empty,
            Email = HttpContext.User.FindFirst(ClaimTypes.Email)?.Value ?? string.Empty,
            IsAuthenticated = HttpContext.User.Identity?.IsAuthenticated ?? false,
            Roles = HttpContext.User.FindAll("role").Select(c => c.Value).ToList()
        };
    }
}
