namespace Sdnd_api.Models;

public class Annotation :BaseEntity
{
    public Guid documentId { get; set; }
    public Guid userId { get; set; }
    public string content { get; set; }
    public string Position { get; set; }
    public string type { get; set; }
    public List<string> tags { get; set; }
}
public class AnnotationRevision
{
    public int Id { get; set; }
    public DateTime RevisionDate { get; set; }
    public string Content { get; set; }
}
