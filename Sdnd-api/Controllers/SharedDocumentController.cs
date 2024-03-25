using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class SharedDocumentsController : ControllerBase
{
    private readonly YourDbContext _context;

    public SharedDocumentsController(YourDbContext context)
    {
        _context = context;
    }

    [HttpGet("{userId}")]
    public async Task<ActionResult<IEnumerable<Document>>> GetSharedDocuments(int userId)
    {
        
        var sharedDocuments = await _context.Documents
            .Where(d => d.SharedWithUserId == userId)
            .ToListAsync();

        return sharedDocuments;
    }
}
