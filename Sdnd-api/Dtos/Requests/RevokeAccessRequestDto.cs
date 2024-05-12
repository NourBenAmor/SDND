namespace Sdnd_api.Dtos.Requests;

public class RevokeAccessRequestDto
{
    public Guid DocumentId { get; set; }
    public Guid UserId { get; set; }
    
}