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

    [HttpPut("Update/{id}")]
    public async Task<IActionResult> UpdateDocument(Guid id, [FromForm] DocumentUpdateModelDto model)
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

        if (HttpContext.Request.Form.Files.Count > 0)
        {
            var uploadedFile = HttpContext.Request.Form.Files[0];
            if (uploadedFile.Length > 0)
            {
                if (!string.IsNullOrEmpty(document.FilePath) && System.IO.File.Exists(document.FilePath))
                {
                    System.IO.File.Delete(document.FilePath);
                }

                document.FileSize = (int)uploadedFile.Length;
                var result = await UploadFile(uploadedFile, id);
                if (result == "file not selected" || result == "file Already Exists")
                {
                    return BadRequest("File Not Uploaded");
                }
                document.FilePath = result;
            }
        }

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

    [HttpGet("Download/{id}")]
    public async Task<IActionResult> DownloadDocument(Guid id)
    {
        try
        {
            var document = await _context.Documents.FindAsync(id);
            if (document == null)
            {
                return NotFound($"Document with ID {id} not found.");
            }

            var filePath = Path.Combine(Directory.GetCurrentDirectory(), document.FilePath);
            var memory = new MemoryStream();
            using (var stream = new FileStream(filePath, FileMode.Open))
            {
                await stream.CopyToAsync(memory);
            }
            memory.Position = 0;

            // Determine the content type based on the file extension or document type
            var contentType = GetContentType(filePath); // Implement GetContentType method
            var fileName = document.Name + ".pdf"; // Set the filename with .pdf extension

            // Set the content-disposition header with the filename
            Response.Headers.Add("content-disposition", $"attachment; filename=\"{fileName}\"");

            return File(memory, contentType, fileName);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while downloading the document: {ex.Message}");
        }
    }

    private string GetContentType(string filePath)
    {
        // Example implementation, you may need to expand this for different file types
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        return extension switch
        {
            ".pdf" => "application/pdf",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            _ => "application/octet-stream",
        };
    }


}
