using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;

namespace Sdnd_api.Models
{
    public class User : IdentityUser<Guid>
    {
        public string ProfilePictureUrl { get; set; } = string.Empty;
    }
}