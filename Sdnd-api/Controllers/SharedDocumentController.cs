using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Dtos.QueryObjects;
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

    [HttpGet("{documentId:guid}/shared-users")]
    public async Task<IActionResult> GetSharedUsers(Guid documentId)
    {
        var document = await _context.Documents.FindAsync(documentId);
        if (document == null)
        {
            return NotFound("Document not found.");
        }

        var sharedDocuments = await _context.SharedDocuments
            .Where(d => d.DocumentId == documentId)
            .Include(sd => sd.Permissions)
            .ToListAsync();

        var userIds = sharedDocuments.Select(sd => sd.SharedWithUserId).Distinct().ToList();
        var users = await _userManager.Users.Where(u => userIds.Contains(u.Id)).ToListAsync();

        var sharedUsers = new List<SharedUserDto>();

        foreach (var sharedDocument in sharedDocuments)
        {
            var user = users.FirstOrDefault(u => u.Id == sharedDocument.SharedWithUserId);
            if (user != null)
            {
                var tasks = await _context.DocTasks
                    .Where(t => t.SharedDocumentId == sharedDocument.Id && t.AssignedUserId == user.Id)
                    .ToListAsync();

                sharedUsers.Add(new SharedUserDto
                {
                    Id = user.Id,
                    Username = user.UserName,
                    Email = user.Email,
                    Permissions = sharedDocument.Permissions.Select(p => p.Id).ToList(),
                    Tasks = tasks
                });
            }
        }

        return Ok(sharedUsers);
    }



    [HttpPost("Share")]
    public async Task<IActionResult> ShareDocument([FromBody] SharedDocRequestDto sharedDoc)
    {
        var userToShareTo = await _userManager.FindByNameAsync(userName: sharedDoc.username);
        var currentUser =   _userAccessor.GetCurrentUser();
        if (currentUser == null )
            return Unauthorized("Login First");
        var document = await _context.Documents.FindAsync(sharedDoc.documentId);
        if (userToShareTo == null || currentUser.Id == userToShareTo.Id )
            return NotFound("Invalid username");
        if (document == null)
            return NotFound("Document not found.");
        
        if (document.OwnerId != currentUser.Id && !await _context.SharedDocuments.AnyAsync(d => d.DocumentId == sharedDoc.documentId && d.SharedWithUserId == currentUser.Id && d.Permissions.Any(p => p.Name == "share")))
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
    public async Task<IActionResult> GetSharedDocument([FromQuery] DocumentQueryObject query)
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
                Id = document.Id,
                Name = document.Name,
                Description = document.Description,
                AddedDate = document.AddedDate,
                UpdatedDate = document.UpdatedDate,
                OwnerUsername = owner.UserName,
                OwnerEmail = owner.Email,
               // OwnerProfilePictureUrl = (string.IsNullOrEmpty(owner.ProfilePictureUrl) ? null : owner.ProfilePictureUrl),
                Permissions = sharedDocument.Permissions.Select(p => p.Id).ToList()
            });
        }
        if (!string.IsNullOrWhiteSpace(query.Name))
            documents = (List<SharedDocumentDto>)documents.Where(s => s.Name.Contains(query.Name));
        if (!string.IsNullOrWhiteSpace(query.Description))
            documents = (List<SharedDocumentDto>)documents.Where(s => s.Description.Contains(query.Description));
        if (query.DocumentState.HasValue)
            documents = (List<SharedDocumentDto>)documents.Where(d => d.DocumentState == query.DocumentState.Value);
        if (query.AddedDateBefore.HasValue)
            documents = (List<SharedDocumentDto>)documents.Where(i => i.AddedDate.Date < query.AddedDateBefore);
        if (query.AddedDateAfter.HasValue)
            documents = (List<SharedDocumentDto>)documents.Where(i => i.AddedDate.Date > query.AddedDateAfter);
        if (query.UpdatedDateBefore.HasValue)
            documents = (List<SharedDocumentDto>)documents.Where(i => i.UpdatedDate.Date < query.UpdatedDateBefore);
        if (query.UpdatedDateAfter.HasValue)
            documents = (List<SharedDocumentDto>)documents.Where(i => i.UpdatedDate.Date > query.UpdatedDateAfter);

        return Ok(documents);
    }
    
    
    // revoke access to a shared document of a user
    [HttpDelete("RevokeAccess")]
    public async Task<IActionResult> RevokeAccess([FromBody] RevokeAccessRequestDto revokeAccessRequest)
    {
        var currentUser = _userAccessor.GetCurrentUser();
        if (currentUser == null)
            return Unauthorized("Login First");
        // get current User permissions on the document
        var document = await _context.Documents.FindAsync(revokeAccessRequest.DocumentId);
        if (document == null)
            return NotFound("Document not found.");
        var isOwner = document.OwnerId == currentUser.Id;
        if (!isOwner)
        {
            return Unauthorized("You are not authorized to make this operation");
        }
        var sharedDocument = await _context.SharedDocuments
            .FirstOrDefaultAsync(d => d.DocumentId == revokeAccessRequest.DocumentId && d.SharedWithUserId == revokeAccessRequest.UserId);
        if (sharedDocument == null)
            return NotFound("Document not shared with this user");
        _context.SharedDocuments.Remove(sharedDocument);
        await _context.SaveChangesAsync();
        return Ok("Successfully removed access to the document.");
    }
}