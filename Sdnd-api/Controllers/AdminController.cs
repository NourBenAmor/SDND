using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Models;

namespace Sdnd_api.Controllers;



//[Authorize(Roles = "Admin")]
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
    public async Task<IActionResult> RemoveRole(Guid id, [FromBody] string role)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null)
        {
            return NotFound();
        }

        var roles = await _userManager.GetRolesAsync(user);
        if (!roles.Contains(role))
        {
            return BadRequest("User does not have the specified role.");
        }

        var result = await _userManager.RemoveFromRoleAsync(user, role);
        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }

        return NoContent();
    }


}