using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;
using Sdnd_Api.Models;
using System.Net.Mime;

namespace Sdnd_api.Controllers;
[ApiController]
[Route("api/[controller]")]
public class FileController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IFileService _fileService;
    private readonly IUserAccessor _userAccessor;
    public FileController(AppDbContext context, IUserAccessor userAccessor,IFileService fileService)
    {
        _context = context;
        _userAccessor = userAccessor;
        _fileService = fileService;
    }
    
    [HttpGet("byDocId")]
    public async Task<IActionResult> GetDocFilesByDocumentId(Guid id)
    {
        if (string.IsNullOrEmpty(id.ToString()))
        {
            return NotFound("Files Id invalid");
        }

        var docFiles = await _fileService.GetDocFilesByDocumentId(id);
        
        if (!docFiles.Any()) // Check if the list is empty using Count
        {
            return NotFound("No Files found for the given DocumentId");
        }
        return Ok(docFiles);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetDocFileById(Guid id)
    {
        if (string.IsNullOrEmpty(id.ToString()))
        {
            return NotFound("File ID invalid");
        }
        var docFile = _context.DocFiles.FirstOrDefault(e => e.Id == id);
        if (docFile == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }
        return Ok(docFile);
    }
    
    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] FileUploadModel model)
    {
        var documentId = model.DocumentId;
        var file = model.File;
        var user = _userAccessor.GetCurrentUser();
        if (user == null)
            return BadRequest("Login First");
        var Document = _context.Documents.FirstOrDefault(x => x.Id == documentId);
        if (Document == null)
            return BadRequest("this Document doesn't exist ");
        
        var newDocFile = new DocFile
        {
            Name = file.FileName,
            FileSize = file.Length,
            DocumentId = documentId
        };
        
        var result = await _fileService.UploadFile(newDocFile, file);
        if (result == "file not selected" || result == "file Already Exists")
            return BadRequest("File Not Uploaded");


        newDocFile.FilePath = result;
        
        _context.DocFiles.Add(newDocFile);
        Document.DocumentState = State.Filled;
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetDocFileById), new { id = newDocFile.Id }, newDocFile);

    }
    [HttpGet("view/{id}")]
    public IActionResult View(string id)
    {
        // Parse the ID string to a Guid
        if (!Guid.TryParse(id, out Guid fileId))
        {
            return BadRequest("Invalid file ID.");
        }

        var docFile = _context.DocFiles.FirstOrDefault(x => x.Id == fileId);

        if (docFile == null)
        {
            return NotFound("File not found.");
        }

        // Assuming you have a service to access the database and retrieve file paths based on IDs
        var filePath = docFile.FilePath;

        var fullPath = Path.Combine(Directory.GetCurrentDirectory(), filePath);

        if (!System.IO.File.Exists(fullPath))
        {
            return NotFound("File not found.");
        }

        // Set the Content-Disposition header to inline to display the PDF in the browser
        var contentDisposition = new System.Net.Mime.ContentDisposition
        {
            FileName = Path.GetFileName(fullPath),
            Inline = true
        };
        Response.Headers.Add("Content-Disposition", contentDisposition.ToString());

        // Set the content type
        Response.ContentType = "application/pdf";

        // Return the file content
        var fileStream = new FileStream(fullPath, FileMode.Open, FileAccess.Read);
        return File(fileStream, "application/pdf");
    }




    [HttpPost("{documentId}/attach-file")]
    public async Task<IActionResult> AttachFileToDocument(Guid documentId, [FromForm] FileUploadModel fileModel)
    {
        var document = await _context.Documents.FindAsync(documentId);

        if (document == null)
        {
            return NotFound($"Document with ID {documentId} not found.");
        }

        if (fileModel.File == null || fileModel.File.Length == 0)
        {
            return BadRequest("No file uploaded or file is empty.");
        }

        var docFile = new DocFile
        {
            DocumentId = documentId, 
            Name = fileModel.File.FileName 
        };


        var filePath = await _fileService.UploadFile(docFile, fileModel.File);

        if (filePath == null)
        {
            return BadRequest("File upload failed.");
        }

        docFile.FilePath = filePath;

        _context.DocFiles.Add(docFile);
        await _context.SaveChangesAsync();

        return Ok(docFile);
    }

}


