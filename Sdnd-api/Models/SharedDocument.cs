using System;
using Sdnd_api.Models;
namespace Sdnd_api.Models
{
    public class SharedDocument : BaseEntity
    {
        public Guid DocumentId { get; set; }
        public Guid SharedWithUserId { get; set; }
    
        public ICollection<SharingPermission> Permissions { get; set; } = new List<SharingPermission>();
        
        public Guid TaskId { get; set; } = Guid.Empty;

    }
}
