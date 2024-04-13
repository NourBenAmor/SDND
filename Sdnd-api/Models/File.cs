using System;
using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Models
{
    public class File : BaseEntity
    {
        [Required]
        public string Name { get; set; }
        public string ContentType { get; set; }
        public string Description { get; set; } = "";
        public string OcrText { get; set; } = string.Empty;
        public int FileSize { get; set; }
        public Guid OwnerId { get; set; }
        
   

        // Foreign key
        public Guid? DocumentId { get; set; }
        // Navigation property
        public Document Document { get; set; }
    }
}