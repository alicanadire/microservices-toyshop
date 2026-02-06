using Duende.IdentityServer.Extensions;
using Duende.IdentityServer.Models;

namespace Identity.API.Services;

public class ProfileService : IProfileService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ILogger<ProfileService> _logger;

    public ProfileService(UserManager<ApplicationUser> userManager, ILogger<ProfileService> logger)
    {
        _userManager = userManager;
        _logger = logger;
    }

    public async Task GetProfileDataAsync(ProfileDataRequestContext context)
    {
        var user = await _userManager.GetUserAsync(context.Subject);
        
        if (user == null)
        {
            _logger.LogError("User not found for subject {SubjectId}", context.Subject.GetSubjectId());
            return;
        }

        var claims = new List<Claim>
        {
            new Claim("sub", user.Id),
            new Claim("email", user.Email ?? string.Empty),
            new Claim("given_name", user.FirstName),
            new Claim("family_name", user.LastName),
            new Claim("name", $"{user.FirstName} {user.LastName}"),
            new Claim("email_verified", user.EmailConfirmed.ToString().ToLower())
        };

        var roles = await _userManager.GetRolesAsync(user);
        foreach (var role in roles)
        {
            claims.Add(new Claim("role", role));
        }

        context.IssuedClaims = claims.Where(x => context.RequestedClaimTypes.Contains(x.Type)).ToList();
    }

    public async Task IsActiveAsync(IsActiveContext context)
    {
        var user = await _userManager.GetUserAsync(context.Subject);
        context.IsActive = user?.IsActive == true;
    }
}
