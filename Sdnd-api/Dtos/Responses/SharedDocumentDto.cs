using Sdnd_api.Models;

namespace Sdnd_api.Dtos.Responses;

public class SharedDocumentDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; } 
    public State DocumentState { get; set; } 
    public DateTime AddedDate { get; set; }
    public DateTime UpdatedDate { get; set; }
    public string OwnerUsername { get; set; }
    public string OwnerEmail { get; set; }
    public string? OwnerProfilePictureUrl => $"https://ui-avatars.com/api/?name={OwnerUsername}&size=128&background=f3d148&rounded=true&color=fff";    
    public List<int> Permissions { get; set; }
}

