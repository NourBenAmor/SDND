using Sdnd_api.Models;

namespace Sdnd_api.Dtos.Responses;

public class SharedDocumentDto
{
    public string Name { get; set; }
    public string Description { get; set; } 
    public State DocumentState { get; set; } 
    public string OwnerUsername { get; set; }
    public string OwnerEmail { get; set; }
    public string OwnerProfilePictureUrl { get; set; }
    public List<int> Permissions { get; set; }
}