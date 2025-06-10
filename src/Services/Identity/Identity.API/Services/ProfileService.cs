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
        try
        {
            var subjectId = context.Subject.GetSubjectId();
            _logger.LogDebug("Getting profile data for subject {SubjectId}", subjectId);

            var user = await _userManager.GetUserAsync(context.Subject);

            if (user == null)
            {
                _logger.LogError("User not found for subject {SubjectId}", subjectId);
                return;
            }

            if (!user.IsActive)
            {
                _logger.LogWarning("Inactive user attempted to get profile data: {UserId}", user.Id);
                return;
            }

            var claims = new List<Claim>
            {
                new Claim("sub", user.Id.ToString()),
                new Claim("email", user.Email ?? string.Empty),
                new Claim("given_name", user.FirstName ?? string.Empty),
                new Claim("family_name", user.LastName ?? string.Empty),
                new Claim("name", user.FullName),
                new Claim("email_verified", user.EmailConfirmed.ToString().ToLower()),
                new Claim("user_id", user.Id.ToString())
            };

            var roles = await _userManager.GetRolesAsync(user);
            foreach (var role in roles)
            {
                claims.Add(new Claim("role", role));
            }

            _logger.LogDebug("Profile data retrieved for user {UserId} with {ClaimCount} claims and {RoleCount} roles",
                user.Id, claims.Count, roles.Count);

            context.IssuedClaims = claims.Where(x => context.RequestedClaimTypes.Contains(x.Type)).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while getting profile data for subject {SubjectId}",
                context.Subject.GetSubjectId());
        }
    }

    public async Task IsActiveAsync(IsActiveContext context)
    {
        try
        {
            var subjectId = context.Subject.GetSubjectId();
            var user = await _userManager.GetUserAsync(context.Subject);

            var isActive = user?.IsActive == true;
            context.IsActive = isActive;

            _logger.LogDebug("User {SubjectId} active status: {IsActive}", subjectId, isActive);

            if (user != null && isActive)
            {
                // Update last login time
                user.LastLoginAt = DateTime.UtcNow;
                await _userManager.UpdateAsync(user);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while checking if user is active for subject {SubjectId}",
                context.Subject.GetSubjectId());
            context.IsActive = false;
        }
    }
}
