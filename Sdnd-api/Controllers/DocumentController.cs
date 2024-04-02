using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using  Sdnd_api.Models;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using System.Net.Mime;
using Microsoft.AspNetCore.Authorization;
using Sdnd_api.Interfaces;
using Sdnd_api.Services;


namespace Sdnd_api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class DocumentController : ControllerBase
{
    private readonly AppDbContext _context;

    private readonly IUserAccessor _userAccessor;
    public DocumentController(AppDbContext context, IUserAccessor userAccessor)
    {
        _context = context;
        _userAccessor = userAccessor;
    }

    [HttpGet]

    public IActionResult GetAll()
    {
        var Documents = _context.Documents.ToList();
        return Ok(Documents);
    }

    [HttpGet("me")]
    public IActionResult Get()
    {
        var user = _userAccessor.GetCurrentUser();

        if (user == null)
            return BadRequest("Login first");
        var userDocuments = _context.Documents
            .Where(d => d.OwnerId == user.Id)
            .ToList();
        return Ok(userDocuments);
    }


    [HttpGet("{id}")]
    public ActionResult<Document> GetDocumentById(Guid id)
    {
        if (string.IsNullOrEmpty(id.ToString()))
        {
            return NotFound("Document ID invalid");
        }
        var document = _context.Documents.FirstOrDefault(e => e.Id == id);
        if (document == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }
        return Ok(document);
    }


    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] FileUploadModel model)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        var user = _userAccessor.GetCurrentUser();
        if (user == null)
            return BadRequest("Login First");
        var newDocument = new Document
        {
            Name = model.Name,
            Description = model.Description,
            FileSize = (int)model.File.Length,
            ContentType = model.contentType,
            Status = 1,
        };
        var result = await UploadFile(model.File, newDocument.Id);
        if (result == "file not selected" || result == "file Already Exists")
            return BadRequest("File Not Uploaded");


        newDocument.FilePath = result;

        newDocument.OwnerId = user.Id;
        _context.Documents.Add(newDocument);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetDocumentById), new { id = newDocument.Id }, newDocument);

    }



    private async Task<string> UploadFile(IFormFile file, Guid DocumentId)
    {
        if (file == null && file.Length == 0)
        {
            return "file not selected";
        }

        var folderName = Path.Combine("Resource", "AllFiles");
        var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);
        if (!Directory.Exists(pathToSave))
            Directory.CreateDirectory(pathToSave);
        var fileName = DocumentId.ToString();
        var fullPath = Path.Combine(pathToSave, fileName);
        var dbPath = Path.Combine(folderName, fileName);

        if (System.IO.File.Exists(fullPath))
            return "file Already Exists";
        await using (var stream = new FileStream(fullPath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        return dbPath;
    }


    [HttpDelete("Delete/{id}")]
    public async Task<IActionResult> DeleteDocument(Guid id)
    {
        try
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
        }
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
        document.ContentType = model.ContentType;
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


    [HttpPut("UpdateFile/{id}")]
    public async Task<IActionResult> UpdateFile(Guid id, [FromForm] FileUpdate model)
    {
        var document = await _context.Documents.FindAsync(id);

        if (document == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }

        if (System.IO.File.Exists(document.FilePath))
        {
            System.IO.File.Delete(document.FilePath);
        }

        var result = await UploadFile(model.File, id);
        if (result == "file not selected" || result == "file Already Exists")
            return BadRequest("File Not Uploaded");

        document.FilePath = result;
        document.FileSize = (int)model.File.Length;

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
