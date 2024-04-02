using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;
using Sdnd_api.Dtos.Responses;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;

namespace Sdnd_api.Services;

public class UserAccessor : IUserAccessor
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserAccessor(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public CurrentUserDto GetCurrentUser()
    {
        var claimsPrincipal = _httpContextAccessor.HttpContext.User;

// Check if the user is authenticated
        if (!claimsPrincipal.Identity.IsAuthenticated)
        {
            return null; // Return unauthorized response if not logged in
        }

        string userEmail= claimsPrincipal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
        string userName = claimsPrincipal.Claims.FirstOrDefault(c => c.Type ==ClaimTypes.Name)?.Value;

// Or access other custom user claims you might have added
        string userId= claimsPrincipal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
            
        return (new CurrentUserDto
        {
            Id = Guid.Parse(userId),
            UserName = userName,
            Email = userEmail,
        });

    }
}