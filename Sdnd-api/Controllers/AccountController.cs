using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
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

    public AccountController(UserManager<User> userManager,IUserAccessor userAccessor,ITokenService tokenService, SignInManager<User> signInManager)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _signInManager = signInManager;
        _userAccessor = userAccessor;
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
        var token = _tokenService.CreateToken(user);
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
        var user = _userAccessor.GetCurrentUser();
        return Ok(user);
    }
}







