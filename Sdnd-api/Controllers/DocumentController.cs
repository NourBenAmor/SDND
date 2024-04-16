using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using  Sdnd_api.Models;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using System.Net.Mime;
using Microsoft.AspNetCore.Authorization;
using Sdnd_api.Dtos.QueryObjects;
using Sdnd_api.Dtos.Responses;
using Sdnd_api.Interfaces;
using Sdnd_api.Services;


namespace Sdnd_api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class DocumentController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IFileService _fileService;
    private readonly IUserAccessor _userAccessor;
    public DocumentController(AppDbContext context, IUserAccessor userAccessor,IFileService fileService)
    {
        _context = context;
        _userAccessor = userAccessor;
        _fileService = fileService;
    }

    [HttpGet]

    public IActionResult GetAll()
    {
        var Documents = _context.Documents.ToList();
        return Ok(Documents);
    }

    
    [HttpGet("me")]
    public IActionResult Get([FromQuery] DocumentQueryObject query)
    {
        var user = _userAccessor.GetCurrentUser();

        if (user == null)
            return BadRequest("Login first");
        var documents = _context.Documents
            .Where(d => d.OwnerId == user.Id)
            .AsQueryable();
        if (!string.IsNullOrWhiteSpace(query.Name))
            documents = documents.Where(s => s.Name.Contains(query.Name));
        if (!string.IsNullOrWhiteSpace(query.Description))
            documents = documents.Where(s => s.Description.Contains(query.Description));
        if (query.DocumentState.HasValue)
            documents = documents.Where(d => d.DocumentState == query.DocumentState.Value);
        if (query.AddedDateBefore.HasValue)
            documents = documents.Where(i => i.AddedDate.Date < query.AddedDateBefore);
        if (query.AddedDateAfter.HasValue)
            documents = documents.Where(i => i.AddedDate.Date > query.AddedDateAfter);
        if (query.UpdatedDateBefore.HasValue)
            documents = documents.Where(i => i.UpdatedDate.Date < query.UpdatedDateBefore);
        if (query.UpdatedDateAfter.HasValue)
            documents = documents.Where(i => i.UpdatedDate.Date > query.UpdatedDateAfter);
        
        return Ok(documents);
    }


    [HttpGet("{id}")]
    public async Task<ActionResult<OneDocumentResponseDto>> GetDocumentById(Guid id)
    {
        if (string.IsNullOrEmpty(id.ToString()))
        {
            return NotFound("Document ID invalid");
        }

        // Fetch the document and handle not found case
        var document = await _context.Documents.FindAsync(id);
        if (document == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }

        // Fetch document files using the file service
        var documentFiles = await _fileService.GetDocFilesByDocumentId(id);

        // Create and populate the response DTO
        var responseDto = new OneDocumentResponseDto
        {
            Name = document.Name,
            Description = document.Description ?? "", // Use null-coalescing for optional Description
            OwnerId = document.OwnerId,
            AddedDate = document.AddedDate,
            UpdatedDate = document.UpdatedDate,
            DocumentState = document.DocumentState,
            Files = documentFiles // Assign the retrieved document files to the Files collection
        };

        return Ok(responseDto);
    }



    [HttpPost("add")]
    public async Task<IActionResult> Post([FromBody] DocumentAddDto newDocument)
    {
        var user = _userAccessor.GetCurrentUser();
        if (user == null)
            return BadRequest("Login first");
        Document document = new Document
        {
            Name = newDocument.Name,
            Description = newDocument.Description,
            OwnerId = user.Id,
        };
        await _context.Documents.AddAsync(document);
        await _context.SaveChangesAsync();
        return Ok(document);
    }



    

    [HttpDelete("Delete/{id}")]
    public async Task<IActionResult> DeleteDocument(Guid id)
    {
        
        // make a method that deletes all the files for that document then delete the document by the doc Id 
        /* try
        {
            var document = await _context.Documents.FindAsync(id);
            if (document == null)
            {
                return NotFound($"Document with ID {id} not found.");
            }
            string filePath = document.FilePath;

            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }

            _context.Documents.Remove(document);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while deleting the document: {ex.Message}");
        }*/
        return StatusCode(500, $"An error occurred while deleting the document");
    }



    [HttpGet("filterByName")]
    public IActionResult FilterByName([FromQuery] string Name)
    {
        if (string.IsNullOrEmpty(Name))
        {
            return BadRequest("Name filter parameter is required.");
        }

        var filteredDocuments = _context.Documents
            .Where(d => d.Name.Contains(Name))
            .ToList();

        return Ok(filteredDocuments);
    }


    // pdf sous forme de url

    [AllowAnonymous]
    [HttpGet("pdf/{id}")]
    public IActionResult Get(Guid id)
    {
        var stream = new FileStream($"Resource/AllFiles/{id.ToString()}", FileMode.Open);
        return File(stream, "application/pdf");
    }

    [HttpPut("UpdateData/{id}")]
    public async Task<IActionResult> UpdateDocumentData(Guid id, [FromBody] DocumentUpdateModelDto model)
    {
        var document = await _context.Documents.FindAsync(id);

        if (document == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }
       

        document.Name = model.Name;
        document.Description = model.Description;
        document.OwnerId = model.OwnerId;
        document.DocumentState = model.DocumentState;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!DocumentExists(id))
            {
                return NotFound($"Document with ID {id} not found.");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }




    private bool DocumentExists(Guid id)
    {
        return _context.Documents.Any(e => e.Id == id);
    }
}
