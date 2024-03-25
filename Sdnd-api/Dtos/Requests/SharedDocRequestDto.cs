namespace Sdnd_api.Dtos.Requests;

public class SharedDocRequestDto
{
    public Guid documentId { get; set; }
    public string username { get; set; }
    public string message { get; set; } = string.Empty;
}