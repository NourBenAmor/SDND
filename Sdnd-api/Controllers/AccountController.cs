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
    private readonly IWebHostEnvironment _hostingEnvironment;


    public AccountController(UserManager<User> userManager,IUserAccessor userAccessor,ITokenService tokenService, SignInManager<User> signInManager, AppDbContext context, IWebHostEnvironment hostingEnvironment)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _signInManager = signInManager;
        _userAccessor = userAccessor;
        _context = context;
        _hostingEnvironment = hostingEnvironment;

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

    [HttpPost("upload-profile-picture/{userId}")]
    public async Task<IActionResult> UploadProfilePicture(string userId, IFormFile imageFile)
    {
        try
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return BadRequest("User not found");

            if (imageFile == null || imageFile.Length == 0)
                return BadRequest("No image file provided");

            var folderName = Path.Combine("Images", userId);
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", folderName);
            if (!Directory.Exists(pathToSave))
                Directory.CreateDirectory(pathToSave);

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
            var fullPath = Path.Combine(pathToSave, fileName);
            var dbPath = Path.Combine(folderName, fileName);

            if (System.IO.File.Exists(fullPath))
                return BadRequest("File already exists");

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await imageFile.CopyToAsync(stream);
            }

            user.ProfilePictureUrl = dbPath;
            await _userManager.UpdateAsync(user);

            return Ok("Profile picture uploaded successfully");
        }
        catch (Exception e)
        {
            return StatusCode(500, e);
        }
    }
    [HttpGet("get-profile-picture/{userId}")]
    public async Task<IActionResult> GetProfilePicture(string userId)
    {
        try
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return NotFound("User not found");

            var folderName = Path.Combine("Images", userId);
            var fileName = Path.GetFileName(user.ProfilePictureUrl);
            var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", folderName, fileName);

            if (!System.IO.File.Exists(imagePath))
                return NotFound("Profile picture not found");

            var imageBytes = await System.IO.File.ReadAllBytesAsync(imagePath);

            return File(imageBytes, "image/jpeg");
        }
        catch (Exception e)
        {
            return StatusCode(500, e);
        }
    }
    



}







