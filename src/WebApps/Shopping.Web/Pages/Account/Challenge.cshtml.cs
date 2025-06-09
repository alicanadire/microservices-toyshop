using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Shopping.Web.Pages.Account;

public class ChallengeModel : PageModel
{
    public IActionResult OnGet(string? returnUrl = null)
    {
        var redirectUrl = !string.IsNullOrEmpty(returnUrl) ? returnUrl : Url.Page("/Index");
        
        return Challenge(
            new AuthenticationProperties { RedirectUri = redirectUrl }, 
            OpenIdConnectDefaults.AuthenticationScheme);
    }
}
