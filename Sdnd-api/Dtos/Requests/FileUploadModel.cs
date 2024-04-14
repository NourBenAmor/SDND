using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Dtos.Requests;

public class FileUploadModel
{
    [Required]
    public IFormFile File { get; set; }

    public Guid DocumentId { get; set; }
    
}