using Sdnd_api.Models;
using Sdnd_Api.Models;

namespace Sdnd_api.Dtos.Responses;

public class OneDocumentResponseDto
{
    public string Name { get; set; }
    public string Description { get; set; } = "";
    public Guid OwnerId { get; set; }
    public DateTime AddedDate { get; set; }
    public DateTime UpdatedDate { get; set; }
    public State DocumentState { get; set; } = State.Blank;
    public ICollection<DocFile> Files { get; set; } = [];
}    
