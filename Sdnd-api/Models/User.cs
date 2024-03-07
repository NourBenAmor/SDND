using Microsoft.AspNetCore.Identity;
namespace Sdnd_api.Models;

public class User : IdentityUser
{
    public string ProfilePictureUrl { get; set; } = string.Empty;
    public ICollection<Document> Documents { get; set; }
}