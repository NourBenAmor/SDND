using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting.Internal;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Dtos.Responses;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;
using System.Security.Claims;

namespace Sdnd_api.Controllers;

[ApiController]
[Route("api/[controller]")]

public class AccountController : ControllerBase
{
    private readonly UserManager<User> _userManager;

    private readonly ITokenService _tokenService;

    private readonly IUserAccessor _userAccessor;

    private readonly SignInManager<User> _signInManager;
    private readonly AppDbContext _context;


    public AccountController(UserManager<User> userManager,IUserAccessor userAccessor,ITokenService tokenService, SignInManager<User> signInManager, AppDbContext context)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _signInManager = signInManager;
        _userAccessor = userAccessor;
        _context = context;

    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto registeruser)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var newUser = new User
            {
                UserName = registeruser.Username,
                Email = registeruser.Email
            };

            if (string.IsNullOrEmpty(registeruser.Password))
            {
                return BadRequest("Password is invalid");
            }

            var createdUser = await _userManager.CreateAsync(newUser, registeruser.Password);

            if (createdUser.Succeeded)
            {
                var roleResult = await _userManager.AddToRoleAsync(newUser, "USER");
                if (roleResult.Succeeded)
                {

                    await _userManager.UpdateAsync(newUser); 

                    NewUserDto userResponse = new NewUserDto
                    {
                        Username = newUser.UserName,
                        Email = newUser.Email,
                    };

                    return Ok(userResponse);
                }
                else
                {
                    return StatusCode(500, roleResult.Errors);
                }
            }
            else
            {
                return StatusCode(500, createdUser.Errors);
            }
        }
        catch (Exception e)
        {
            return StatusCode(500, e);
        }
    }


    [HttpPost("login")]
    public async Task<IActionResult> login(LoginDto loginDto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        var user = _userManager.Users.FirstOrDefault(x => x.UserName == loginDto.Username);
        if (user == null) return Unauthorized("Invalid Username");
        var result = await _signInManager.CheckPasswordSignInAsync(user, loginDto.Password, false);
        if (!result.Succeeded) return Unauthorized("Username not found and/or password incorrect");
        var token = await _tokenService.CreateToken(user);
        return Ok(new NewUserDto
        {
            Id = user.Id,
            Username = user.UserName,
            Email = user.Email,
            Token = token
        });
    }



    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser()
    {
        var currentUserDto = _userAccessor.GetCurrentUser(); // Assuming this method returns the current user's information

        if (currentUserDto == null)
        {
            return Unauthorized(); // Return unauthorized response if user is not logged in
        }

        var user = await _userManager.FindByIdAsync(currentUserDto.Id.ToString()); // Fetch the user from the UserManager

        if (user == null)
        {
            return NotFound();
        }

        return Ok(user);
    }



    [HttpPut("update/{userId}")]
    public async Task<IActionResult> UpdateUserById(string userId, [FromBody] User updatedUser)
    {
        try
        {
            var userToUpdate = await _userManager.FindByIdAsync(userId);
            if (userToUpdate == null)
                return NotFound("User not found");

            userToUpdate.UserName = updatedUser.UserName;
            userToUpdate.Email = updatedUser.Email;

            var result = await _userManager.UpdateAsync(userToUpdate);
            if (result.Succeeded)
            {
                var updatedUserData = await _userManager.FindByIdAsync(userId);
                return Ok(updatedUserData); 
            }
            else
            {
                return StatusCode(500, result.Errors);
            }
        }
        catch (Exception e)
        {
            return StatusCode(500, e);
        }
    }
    [HttpGet("usernames")]
    public async Task<IActionResult> GetAllUsernames()
    {
        var users = await _userManager.Users.ToListAsync(); // Fetch all users from UserManager

        if (users == null || users.Count == 0)
        {
            return NotFound("No users found");
        }

        var usernames = users.Select(u => u.UserName).ToList();

        return Ok(usernames);
    }

    [HttpGet("users/total-count")]
    public async Task<IActionResult> GetTotalNumberOfUsers()
    {
        try
        {
            // Retrieve the total count of users
            var totalUsersCount = await _context.Users.CountAsync();

            return Ok(totalUsersCount);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while retrieving total users count: {ex.Message}");
        }
    }


}







