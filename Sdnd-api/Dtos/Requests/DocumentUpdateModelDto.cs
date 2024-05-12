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
    }
}
