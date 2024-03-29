using Sdnd_api.Models;
using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Dtos.Requests
{
    public class DocumentUpdateModelDto
    {
        [Required]
        public string Name { get; set; }
        public string ContentType { get; set; }
        public string Description { get; set; }
        public Guid OwnerId { get; set; }
        public State DocumentState { get; set; }
        public IFormFile? File { get; set; } // Nullable IFormFile property
    }
}
