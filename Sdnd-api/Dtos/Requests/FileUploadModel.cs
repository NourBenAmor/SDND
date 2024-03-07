using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Dtos.Requests;

public class FileUploadModel
{
    [Required]
    public string Name { get; set; }
    public IFormFile File { get; set; }
    public string contentType { get; set; }
    public string Description { get; set; }
    public Guid ownerId{ get; set; }
}