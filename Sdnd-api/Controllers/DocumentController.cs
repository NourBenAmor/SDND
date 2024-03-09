using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using  Sdnd_api.Models;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;


namespace Sdnd_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DocumentController : ControllerBase
{
    private readonly AppDbContext _context;
    public DocumentController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public  IActionResult GetAll()
    {
        var Documents =  _context.Documents.ToList();
        return Ok(Documents);
    }


    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] FileUploadModel model)
    {
        var result = await UploadFile(model.File);
        if (result == "file not selected" || result =="file Already Exists")
            return BadRequest("File Not Uploaded");
        var newDocument = new Document
        {
            Name = model.Name,
            Description = model.Description,
            FilePath = result,
            OwnerId = model.ownerId,
            ContentType = model.contentType
        };

        var document =  _context.Documents.Add(newDocument);
        await _context.SaveChangesAsync();

        return Ok(document);

    }


    private async Task<string> UploadFile(IFormFile file)
    {
        if (file == null && file.Length == 0)
        {
            return "file not selected";
        }

        var folderName = Path.Combine("Resource", "AllFiles ");
        var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);
        if (!Directory.Exists(pathToSave))
            Directory.CreateDirectory(pathToSave);
        var fileName = file.FileName;
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

    
}