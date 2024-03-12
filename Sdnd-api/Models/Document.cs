using System;
using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Models
{
    public class Document : BaseEntity
    {
        [Required]
        public string Name { get; set; }
        public string ContentType { get; set; }
        public string Description { get; set; } = "";
        public string OcrText { get; set; } = string.Empty;
        public int FileSize { get; set; }
        public Guid OwnerId { get; set; }
        public string FilePath { get; set; }
        public State DocumentState { get; set; } = State.Uploaded;
    }

    public enum State
    {
        Uploaded,
        OcrPending,
        Signed
    }
}
