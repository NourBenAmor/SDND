using Microsoft.AspNetCore.Mvc;
using System;
using System.ComponentModel.DataAnnotations;

namespace Sdnd_api.Models
{
    public class Document : BaseEntity
    {
        [Required]
        public string Name { get; set; }
        public string Description { get; set; } = "";
        public Guid OwnerId { get; set; }
        public State DocumentState { get; set; } = State.Blank;

    }

    public enum State 
    {
        Blank,
        Filled,
        Shared,
        Archived
    }
    
}
