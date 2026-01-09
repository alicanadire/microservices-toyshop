using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Duende.IdentityServer.Services;
using Identity.API.ViewModels;

namespace Identity.API.Controllers;

[AllowAnonymous]
public class AccountController : Controller
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IIdentityServerInteractionService _interaction;
    private readonly ILogger<AccountController> _logger;

    public AccountController(
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager,
        IIdentityServerInteractionService interaction,
        ILogger<AccountController> logger)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _interaction = interaction;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> Login(string? returnUrl = null)
    {
        var context = await _interaction.GetAuthorizationContextAsync(returnUrl);
        
        var vm = new LoginViewModel
        {
            ReturnUrl = returnUrl,
            Username = context?.LoginHint ?? string.Empty
        };

        return View(vm);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var user = await _userManager.FindByEmailAsync(model.Username) 
                  ?? await _userManager.FindByNameAsync(model.Username);

        if (user != null)
        {
            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, lockoutOnFailure: true);
            
            if (result.Succeeded)
            {
                await _signInManager.SignInAsync(user, model.RememberMe);
                
                // Update last login time
                user.LastLoginAt = DateTime.UtcNow;
                await _userManager.UpdateAsync(user);

                if (!string.IsNullOrEmpty(model.ReturnUrl) && Url.IsLocalUrl(model.ReturnUrl))
                {
                    return Redirect(model.ReturnUrl);
                }
                
                return Redirect("~/");
            }
        }

        ModelState.AddModelError(string.Empty, "Invalid username or password");
        return View(model);
    }

    [HttpGet]
    public IActionResult Register(string? returnUrl = null)
    {
        var vm = new RegisterViewModel
        {
            ReturnUrl = returnUrl
        };
        
        return View(vm);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Register(RegisterViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var user = new ApplicationUser
        {
            UserName = model.Email,
            Email = model.Email,
            FirstName = model.FirstName,
            LastName = model.LastName,
            EmailConfirmed = true // For demo purposes
        };

        var result = await _userManager.CreateAsync(user, model.Password);
        
        if (result.Succeeded)
        {
            await _userManager.AddToRoleAsync(user, "Customer");
            await _signInManager.SignInAsync(user, isPersistent: false);
            
            if (!string.IsNullOrEmpty(model.ReturnUrl) && Url.IsLocalUrl(model.ReturnUrl))
            {
                return Redirect(model.ReturnUrl);
            }
            
            return Redirect("~/");
        }

        foreach (var error in result.Errors)
        {
            ModelState.AddModelError(string.Empty, error.Description);
        }

        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Logout(string? logoutId = null)
    {
        await _signInManager.SignOutAsync();
        
        var logout = await _interaction.GetLogoutContextAsync(logoutId);
        
        if (!string.IsNullOrEmpty(logout?.PostLogoutRedirectUri))
        {
            return Redirect(logout.PostLogoutRedirectUri);
        }
        
        return Redirect("~/");
    }
}
