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
using Sdnd_Api.Models;
using Task = System.Threading.Tasks.Task;


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

            // Find shared documents associated with the document
            var sharedDocuments = await _context.SharedDocuments.Where(sd => sd.DocumentId == id).ToListAsync();

            // Remove the associated shared documents
            _context.SharedDocuments.RemoveRange(sharedDocuments);

            // Delete associated files, if any
            await DeleteDocumentFiles(document.Id);

            // Remove the document
            _context.Documents.Remove(document);

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while deleting the document: {ex.Message}");
        }
    }




    private async Task DeleteDocumentFiles(Guid documentId)
    {
        var docFiles = await _context.DocFiles
            .Where(df => df.DocumentId == documentId)
            .ToListAsync();

        foreach (var docFile in docFiles)
        {


            _context.DocFiles.Remove(docFile);
        }

        await _context.SaveChangesAsync();
    }



    [HttpPost("add")]
    public async Task<IActionResult> Post([FromBody] DocumentAddDto newDocument)
    {
        var user = _userAccessor.GetCurrentUser();
        if (user == null)
            return Unauthorized("Login first");
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
    
        [AllowAnonymous]
        [HttpGet("pdf/{id}/{version?}")]
        public IActionResult Get(Guid id, int? version)
        {
            var folderName = Path.Combine("Resource", "AllFiles");
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);

            // Use a regular expression to remove any existing version number from the filename
            var fileName = id.ToString();

            // Get all files that start with the same id
            var files = Directory.GetFiles(pathToSave, $"{fileName}*");

            // Extract version numbers from filenames
            var versionNumbers = files.Select(file =>
            {
                var versionString = Path.GetFileNameWithoutExtension(file).Replace(fileName, "").Replace("_", "");
                int fileVersion;
                return int.TryParse(versionString, out fileVersion) ? fileVersion : 0;
            });

            // Determine the highest version number
            var latestVersionNumber = versionNumbers.Any() ? versionNumbers.Max() : 1;

            // If a version number is provided, use it. Otherwise, use the latest version number.
            var selectedVersionNumber = version ?? latestVersionNumber;

            // Append the version number to the filename
            var fullPath = Path.Combine(pathToSave, $"{fileName}_{selectedVersionNumber}");

            if (!System.IO.File.Exists(fullPath))
            {
                return NotFound("The requested version of the file does not exist.");
            }

            var stream = new FileStream(fullPath, FileMode.Open, FileAccess.ReadWrite, FileShare.ReadWrite);
            return File(stream, "application/pdf");
        }

        [AllowAnonymous]
        [HttpGet("pdf/{id}/versions")]
        public IActionResult GetVersions(Guid id)
        {
            var folderName = Path.Combine("Resource", "AllFiles");
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);

            // Use a regular expression to remove any existing version number from the filename
            var fileName = id.ToString();

            // Get all files that start with the same id
            var files = Directory.GetFiles(pathToSave, $"{fileName}*");

            // Extract version numbers from filenames
            var versionNumbers = files.Select(file =>
            {
                var versionString = Path.GetFileNameWithoutExtension(file).Replace(fileName, "").Replace("_", "");
                int fileVersion;
                return int.TryParse(versionString, out fileVersion) ? fileVersion : 0;
            })
            .OrderBy(v => v)
            .ToList();

            return Ok(versionNumbers);
        }

        [AllowAnonymous]
    [HttpGet("pdf/second/{id}")]
    public IActionResult GetSecond(Guid id)
    {
        try
        {
            // Ensure that the file exists
            string filePath = $"Resource/AllFiles/{id.ToString()}";
            if (!System.IO.File.Exists(filePath))
            {
                return NotFound("not found"); // Return 404 if the file does not exist
            }

            // Read the file as a byte array
            byte[] fileBytes = System.IO.File.ReadAllBytes(filePath);

            // Return the file as a byte array with the appropriate content type
            return File(fileBytes, "application/pdf", $"{id}.pdf");
        }
        catch (Exception ex)
        {
            // Log the error
            Console.WriteLine($"Error retrieving PDF file: {ex.Message}");
            return StatusCode(500); // Return 500 Internal Server Error
        }
    }
    
    [HttpPut("UpdateData/{id}")]
    public async Task<IActionResult> UpdateDocumentData(Guid id, [FromBody] DocumentUpdateModelDto model)
    {
        var document = await _context.Documents.FindAsync(id);
        var CurrentUser = _userAccessor.GetCurrentUser();
        if (CurrentUser == null)
            return Unauthorized("Login first");
        if (CurrentUser.Id != document.OwnerId && !await _context.SharedDocuments.AnyAsync(d =>
                d.DocumentId == id && d.SharedWithUserId == CurrentUser.Id && d.Permissions.Any(p => p.Name == "edit")))
            return Unauthorized("You are not authorized to update this document");
        if (document == null)
        {
            return NotFound($"Document with ID {id} not found.");
        }
        document.Name = model.Name;
        document.Description = model.Description;
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

    [HttpGet("{documentId}/files")]
    public async Task<IActionResult> GetFilesOfDocument(Guid documentId)
    {
        var document = await _context.Documents.FindAsync(documentId);

        if (document == null)
        {
            return NotFound($"Document with ID {documentId} not found.");
        }

        var docFiles = await _context.DocFiles
            .Where(df => df.DocumentId == documentId)
            .ToListAsync();

        return Ok(docFiles);
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

    [HttpGet("statistics")]
    public IActionResult GetDocumentStatistics()
    {
        try
        {
            var totalDocuments = _context.Documents.Count();

            var documentsByState = _context.Documents
                .GroupBy(d => d.DocumentState)
                .Select(g => new { State = g.Key, Count = g.Count() })
                .ToList();



            var statisticsResponse = new
            {
                TotalDocuments = totalDocuments,
                DocumentsByState = documentsByState,
            };

            return Ok(statisticsResponse);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while fetching document statistics: {ex.Message}");
        }
    }

    [HttpGet("added-document-stats")]
    public async Task<IActionResult> GetDocumentAddedStats()
    {
        try
        {
            var currentUser = _userAccessor.GetCurrentUser();
            if (currentUser == null)
                return Unauthorized("Login first");

            var addedDocuments = await _context.Documents
                .Where(d => d.OwnerId == currentUser.Id)
                .ToListAsync();

            var monthlyDocumentUploads = addedDocuments
                .GroupBy(d => new { Year = d.AddedDate.Year, Month = d.AddedDate.Month })
                .Select(g => new { Year = g.Key.Year, Month = g.Key.Month, Count = g.Count() })
                .OrderBy(g => g.Year)
                .ThenBy(g => g.Month)
                .ToList();

            var monthlyDocumentAddedTable = new int[12];
            foreach (var item in monthlyDocumentUploads)
            {
                monthlyDocumentAddedTable[item.Month - 1] += item.Count;
            }

            var stats = new
            {
                TotalDocumentUploads = addedDocuments.Count,
                MonthlyDocumentUploadsTable = monthlyDocumentAddedTable,
                MonthNames = new string[] { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"An error occurred while retrieving document upload stats: {ex.Message}");
        }
    }


    






}
