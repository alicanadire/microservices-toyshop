using System.ComponentModel.DataAnnotations;

namespace Identity.API.ViewModels;

public class LoginViewModel
{
    [Required]
    [Display(Name = "Email or Username")]
    public string Username { get; set; } = default!;

    [Required]
    [DataType(DataType.Password)]
    public string Password { get; set; } = default!;

    [Display(Name = "Remember me")]
    public bool RememberMe { get; set; }

    public string? ReturnUrl { get; set; }
}
