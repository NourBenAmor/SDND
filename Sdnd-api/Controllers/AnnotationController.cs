using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class AnnotationsController : ControllerBase
{
    private readonly YourDbContext _context;

    public AnnotationsController(YourDbContext context)
    {
        _context = context;
    }


    [HttpPost]
    public async Task<ActionResult<Annotation>> PostAnnotation(Annotation annotation)
    {
        _context.Annotations.Add(annotation);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAnnotationsForDocument), new { documentId = annotation.DocumentId }, annotation);
    }

    [HttpGet("{documentId}")]
    public async Task<ActionResult<IEnumerable<Annotation>>> GetAnnotationsForDocument(int documentId)
    {
        var annotations = await _context.Annotations.Where(a => a.DocumentId == documentId).ToListAsync();
        if (annotations == null)
        {
            return NotFound();
        }

        return annotations;
    }
}
