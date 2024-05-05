namespace Sdnd_api.Dtos.Requests;

public class SharedDocRequestDto
{
    public Guid documentId { get; set; }
    public string username { get; set; }
    public string TaskDescription { get; set; }= "";
    public List<int> permissionIds { get; set; }
}