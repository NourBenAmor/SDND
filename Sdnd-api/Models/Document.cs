using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Models;

public class Document : BaseEntity
{
    [Required]
    public string Name { get; set; }
    public string contentType { get; set; }
    public string Description { get; set; }
    public string ocrText { get; set; } = string.Empty;
    public int fileSize { get; set; }
    public Guid ownerId { get; set; }
    public string filePath { get; set; }
    public State documentState { get; set; } = State.Uploaded;
    public User Owner { get; }
}
    public enum State
    {
        Uploaded ,
        OcrPending,
        Signed
    }

