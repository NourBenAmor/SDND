namespace Sdnd_api.Dtos.Responses;

public class CommentResponseDto
{
    public Guid Id { get; set; }
    public string? username { get; set; }
    public string profilePictureurl => $"https://ui-avatars.com/api/?name={username}&size=128&background=f3d148&rounded=true&color=fff";    
    public string commentText { get; set; }
    public DateTime addedDate { get; set; }
}