namespace Shopping.Web.Models.Identity;

public class UserViewModel
{
    public string Id { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public string LastName { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string FullName => $"{FirstName} {LastName}";
    public List<string> Roles { get; set; } = new();
    public bool IsAuthenticated { get; set; }
}
