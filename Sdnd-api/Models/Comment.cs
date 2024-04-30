namespace Sdnd_api.Models;

public class Comment : BaseEntity
{
    public Guid UserId { get; set; }
    
    public Guid DocumentId { get; set; }
    
    required 
    public string CommentText {  get; set; }
    
}