using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;
using Sdnd_Api.Models;

[Route("api/[controller]")]
[ApiController]
public class AnnotationController : ControllerBase
{
    
    private readonly AppDbContext _context;
    private readonly IFileService _fileService;
    private readonly IUserAccessor _userAccessor;
    public AnnotationController(AppDbContext context, IUserAccessor userAccessor,IFileService fileService)
    {
        _context = context;
        _userAccessor = userAccessor;
        _fileService = fileService;
    }
    
    [HttpPost("NewVersion")]
    public async Task<IActionResult> Update([FromForm] FileUpdateRequest model)
    {
        var file = model.file;
        //var user = _userAccessor.GetCurrentUser();
        //if (user == null)
            //return Unauthorized("Login First");
        //var Docfile = _context.DocFiles.FirstOrDefault(x => x.Id == Guid.Parse(file.Name));
        //if (Docfile == null)
            //return BadRequest("this Document doesn't exist ");
        var result = await _fileService.UpdateFile(file);
        if (result == "file not selected" || result == "file Already Exists")
            return BadRequest("File Not Uploaded");
        return Ok("Succeded");
    }
}
