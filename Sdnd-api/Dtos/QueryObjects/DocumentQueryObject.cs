using Sdnd_api.Models;

namespace Sdnd_api.Dtos.QueryObjects;

public class DocumentQueryObject
{
    public string? Name { get; set; } = null;
    public string? Description { get; set; } = null;
    public State? DocumentState { get; set; } = null;
    public DateTime? AddedDateBefore { get; set; }= null;
    public DateTime? AddedDateAfter { get; set; } = null;
    public DateTime? UpdatedDateBefore { get; set; } = null;
    public DateTime? UpdatedDateAfter { get; set; } = null;
}
