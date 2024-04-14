using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Interfaces;
using Sdnd_Api.Models;

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
            Name = file.Name,
            FileSize = file.Length,
            DocumentId = documentId
        };
        var result = await _fileService.UploadFile(newDocFile, file);
        if (result == "file not selected" || result == "file Already Exists")
            return BadRequest("File Not Uploaded");


        newDocFile.FilePath = result;

        _context.DocFiles.Add(newDocFile);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetDocFileById), new { id = newDocFile.Id }, newDocFile);

    }

    
}


