using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Models;

namespace Sdnd_api.Controllers;



[Authorize(Roles = "Admin")]
[Route("api/")]
[ApiController]
public class AdminController : ControllerBase
{
    private readonly UserManager<User> _userManager;
    
    public AdminController(UserManager<User> userManager)
    {
        _userManager = userManager;
    }
    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        var users = await _userManager.Users.ToListAsync();

        var userDtos = new List<object>();

        foreach (var user in users)
        {
            var roles = await _userManager.GetRolesAsync(user);
            var userDto = new
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                Role = roles.FirstOrDefault() 
                // This will get the first role if there are multiple
            };
            userDtos.Add(userDto);
        }

        return Ok(userDtos);
    }
    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser()
    {
        var user = await _userManager.GetUserAsync(User);
        if (user == null)
        {
            return NotFound();
        }

        var roles = await _userManager.GetRolesAsync(user);

        var userModel = new
        {
            Id = user.Id,
            Username = user.UserName,
            Email = user.Email,
            Roles = roles // Include roles in the response
        };

        return Ok(userModel);
    }

    //  PUT: api/Account/changeRole/{id}
    [HttpPut("addRole/{id}")]
    public async Task<IActionResult> AddRole(Guid id,[FromBody] string role)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null)
        {
            return NotFound();
        }
        var roles = await _userManager.GetRolesAsync(user);
        await _userManager.RemoveFromRolesAsync(user, roles);
        var result = await _userManager.AddToRoleAsync(user, role);
        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }
        return NoContent();
    }
    /*[HttpDelete("removeRole/{id}")]
    public async Task<IActionResult> RemoveRole(Guid id, [FromBody] string role)
    {
        IEnumerable<string> roles = Array.Empty<string>();
        roles.Append(role);
        var user = await _userManager.FindByIdAsync(id.ToString());
        await _userManager.RemoveFromRolesAsync(user, roles);
        return NoContent();
    }*/
    [HttpPut("removeRole/{id}")]
    public async Task<IActionResult> RemoveRole(Guid id)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null)
        {
            return NotFound();
        }

        var result = await _userManager.RemoveFromRoleAsync(user, "Admin");
        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }

        var roles = await _userManager.GetRolesAsync(user);
        if (roles.Count == 0)
        {
            var addUtilisateurRoleResult = await _userManager.AddToRoleAsync(user, "User");
            if (!addUtilisateurRoleResult.Succeeded)
            {
                return BadRequest(addUtilisateurRoleResult.Errors);
            }
        }

        return NoContent();
    }

}