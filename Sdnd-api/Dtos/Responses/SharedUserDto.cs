using Sdnd_api.Models;

namespace Sdnd_api.Dtos.Responses;

public class SharedUserDto
{
    public Guid Id { get; set; }
    public string  Username { get; set; }
    public string Email { get; set; }
    public string ProfilePictureUrl => $"https://ui-avatars.com/api/?name={Username}&size=128&background=f3d148&rounded=true&color=fff";

    public List<int> Permissions { get; set; } = [];
   
    public List<DocTask> Tasks { get; set; } = [];
    
}