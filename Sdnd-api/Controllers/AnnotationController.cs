using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Sdnd_api.Data;
using Sdnd_api.Models;

[Route("api/[controller]")]
[ApiController]
public class AnnotationsController : ControllerBase
{
    private readonly AppDbContext _context;

    public AnnotationsController(AppDbContext context)
    {
        _context = context;
    }


   /* public async Task<IActionResult> MakeAnnotation()
    {
        
    }*/


    [HttpPost]
    public async Task<ActionResult<Annotation>> PostAnnotation(Annotation annotation)
    {
        _context.Annotations.Add(annotation);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAnnotationsForDocument), new { documentId = annotation.documentId }, annotation);
    }

    [HttpGet("{documentId}")]
    public async Task<ActionResult<IEnumerable<Annotation>>> GetAnnotationsForDocument(Guid documentId)
    {
        var annotations = await _context.Annotations.Where(a => a.documentId == documentId).ToListAsync();
        if (annotations == null)
        {
            return NotFound();
        }

        return annotations;
    }

    [HttpPost("saveAnnotations")]
    public async Task<IActionResult> AllAnnotations([FromBody] Object data)
    {
        return Accepted(data);
    }
    
}
