using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
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
            .Where(d => d.DocumentId == documentId).Include(sharedDocument => sharedDocument.Permissions);
        List<SharedUserDto> sharedUsers = new List<SharedUserDto>();
        foreach (var sharedDocument in sharedDocuments)
        {
            var user = await _userManager.FindByIdAsync(sharedDocument.SharedWithUserId.ToString());
            sharedUsers.Add(new SharedUserDto
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                ProfilePictureUrl = user.ProfilePictureUrl,
                Permissions = sharedDocument.Permissions.Select(p => p.Id).ToList(),
                Tasks = await _context.DocTasks.Where(t => t.SharedDocumentId == documentId && t.AssignedUserId == user.Id).ToListAsync()
            });
        }

        return Ok(sharedUsers);
    }



    [HttpPost("Share")]
    public async Task<IActionResult> ShareDocument([FromBody] SharedDocRequestDto sharedDoc)
    {
        var userToShareTo = await _userManager.FindByNameAsync(userName: sharedDoc.username);
        var currentUser =   _userAccessor.GetCurrentUser();
        if (currentUser == null)
            return Unauthorized("Login First");
        var document = await _context.Documents.FindAsync(sharedDoc.documentId);
        if (userToShareTo == null || currentUser.Id == userToShareTo.Id )
            return NotFound("Invalid username");
        if (document == null)
            return NotFound("Document not found.");
        if (document.OwnerId != currentUser.Id)
            return Unauthorized("You are not authorized to make this operation");
        var sharedDocumentExists = await _context.SharedDocuments
            .AnyAsync(d => d.DocumentId == sharedDoc.documentId && d.SharedWithUserId == userToShareTo.Id);
        if (sharedDocumentExists)
            return BadRequest("Document already shared with this user");
        
        // Retrieve the permissions from the database
        var permissions = await  _context.SharingPermissions
            .Where(p => sharedDoc.permissionIds.Any(id => id == p.Id))
            .ToListAsync();
        // Create a new Task
        DocTask docTask = null;
        if (sharedDoc.TaskDescription != "")
        {
            docTask = new DocTask
            {
                Description = sharedDoc.TaskDescription,
                State = TaskState.Pending,
                SharedDocumentId = sharedDoc.documentId,
                AssignedUserId = userToShareTo.Id
            };  
        }
        SharedDocument sharedDocument = new SharedDocument
        {
            DocumentId = document.Id,
            SharedWithUserId = userToShareTo.Id,
            Permissions = permissions
        };
        try
        {
            await _context.SharedDocuments.AddAsync(sharedDocument);
            if (docTask != null) await _context.DocTasks.AddAsync(docTask);
            await _context.SaveChangesAsync();
            return Ok("Success");
        }
        catch (System.Exception e)
        {
            return BadRequest(e);
        }
        
        
    }


    [HttpGet("SharedWithMe")]
    public async Task<IActionResult> GetSharedDocument()
    {
        var currentUser = _userAccessor.GetCurrentUser();
        if (currentUser == null)
            return Unauthorized("Login First");
        IEnumerable<SharedDocument> sharedDocuments = await _context.SharedDocuments
            .Where(d => d.SharedWithUserId == currentUser.Id).Include(sharedDocument => sharedDocument.Permissions)
            .ToListAsync();

        List<SharedDocumentDto> documents = new List<SharedDocumentDto>();
        foreach (var sharedDocument in sharedDocuments)
        {
            var document = await _context.Documents.FirstOrDefaultAsync(x => x.Id == sharedDocument.DocumentId);
            var owner = await _userManager.FindByIdAsync(document.OwnerId.ToString());
            documents.Add(new SharedDocumentDto
            {
                Name = document.Name,
                Description = document.Description,
                OwnerUsername = owner.UserName,
                OwnerEmail = owner.Email,
                OwnerProfilePictureUrl = owner.ProfilePictureUrl,
                Permissions = sharedDocument.Permissions.Select(p => p.Id).ToList()
            });
        }
        return Ok(documents);
    }
}