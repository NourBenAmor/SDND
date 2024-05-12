namespace Sdnd_api.Dtos.Requests;

public class AddCommentDto
{
    public string Text { get; set; }
    public Guid DocumentId { get; set; }
}