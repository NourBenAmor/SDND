namespace Sdnd_api.Models;

public class SharedDocument : BaseEntity 
{
    public Guid DocumentId { get; set; }
    public Guid SharedWithUserId { get; set;}
    public PermissionLevel PermissionLevel { get; set; } = PermissionLevel.View;
}
public enum PermissionLevel
{
    View,
    Edit,
    FullControl
}