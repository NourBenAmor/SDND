using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Responses;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;

namespace Sdnd_api.Controllers;

[ApiController]
[Route("api/Document/")]
public class ShareController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly UserManager<User> _userManager;
    private readonly IUserAccessor _userAccessor;

    public ShareController(AppDbContext context, IUserAccessor userAccessor,UserManager<User> userManager)
    {
        _context = context;
        _userAccessor = userAccessor;
        _userManager = userManager;
    }

    [HttpGet("{documentId}/shared-users")]
    public async Task<IActionResult> GetSharedUsers(Guid documentId)
    {
        var document = await _context.Documents.FindAsync(documentId);
        if (document == null)
        {
            return NotFound("Document not found.");
        }
        
        IEnumerable<SharedDocument> sharedDocuments = _context.SharedDocuments
            .Where(d => d.DocumentId == documentId);

        List<SharedUserDto> sharedUsers = new List<SharedUserDto>();
        foreach (var sharedDocument in sharedDocuments )
        {
            var user = await _userManager.FindByIdAsync(sharedDocument.SharedWithUserId.ToString());
            sharedUsers.Add(new SharedUserDto
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                ProfilePictureUrl = user.ProfilePictureUrl
            });
        }

        return Ok(sharedUsers);
    }



    [HttpPost("Share")]
    public async Task<IActionResult> ShareDocument(Guid documentId, string username)
    {
        var userToShareTo = await _userManager.FindByNameAsync(userName: username);
        if (userToShareTo == null)
            return NotFound("Invalid username");
        var currentUser =   _userAccessor.GetCurrentUser();
        if (currentUser == null)
            return BadRequest("Login First");
        var document = await _context.Documents.FindAsync(documentId);
        if (document == null)
            return NotFound("Document not found.");
        if (document.OwnerId != currentUser.Id)
            return Unauthorized("You are not authorized to make this operation");
        SharedDocument sharedDocument = new SharedDocument
        {
            DocumentId = document.Id,
            SharedWithUserId = userToShareTo.Id
        };
        var result = await _context.SharedDocuments.AddAsync(sharedDocument);
        await _context.SaveChangesAsync();
        return Ok(result);
    }


    [HttpGet("SharedWithMe")]
    public async Task<IActionResult> GetSharedDocument()
    {
        var currentUser = _userAccessor.GetCurrentUser();
        IEnumerable<SharedDocument> sharedDocuments = _context.SharedDocuments
            .Where(d => d.SharedWithUserId == currentUser.Id);

        List<Document> documents = new List<Document>();
        foreach (var sharedDocument in sharedDocuments )
        {
            var document = await _context.Documents.FirstOrDefaultAsync(x => x.Id == sharedDocument.DocumentId);
            documents.Add(document);
        }

        return Ok(documents);
    }
    
}