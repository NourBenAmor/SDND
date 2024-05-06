namespace Sdnd_api.Dtos.Requests;

public class SignatureRequestDto
{
    public Guid FileId { get; set; }
    public string SignatureImg { get; set; }
    public int PageNumber { get; set; }
}