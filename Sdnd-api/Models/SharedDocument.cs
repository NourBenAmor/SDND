using System;

namespace Sdnd_api.Models
{
    public class SharedDocument : BaseEntity
    {
        public Guid DocumentId { get; set; }
        public Guid SharedWithUserId { get; set; }
    }
}
