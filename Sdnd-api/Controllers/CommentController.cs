using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;

namespace Sdnd_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    
    [Authorize]
    public class CommentController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IUserAccessor _userAccessor;


        public CommentController(AppDbContext context , IUserAccessor userAccessor)
        {
            _context = context;
            _userAccessor = userAccessor;
        }

        // GET: api/Comment?documentId={documentId}
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Comment>>> GetComments(Guid documentId)
        {
            return await _context.Comments
                .Where(c => c.DocumentId == documentId)
                .OrderByDescending(c =>c.AddedDate)
                .ToListAsync();
        }
        
        // GET: api/Comment/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Comment>> GetComment(Guid id)
        {
            var comment = await _context.Comments.FindAsync(id);
            
            if (comment == null)
            {
                return NotFound();
            }

            return comment;
        }

        // POST: api/Comment
        [HttpPost]
        public async Task<ActionResult<Comment>> CreateComment(Comment comment)
        {
            comment.UserId = _userAccessor.GetCurrentUser().Id;
            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetComment), new { id = comment.Id }, comment);
        }

        // PUT: api/Comment/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateComment(Guid id, Comment comment)
        {
            if (id != comment.Id)
            {
                return BadRequest();
            }

            _context.Entry(comment).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/Comment/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteComment(Guid id)
        {
            var comment = await _context.Comments.FindAsync(id);

            if (comment == null)
            {
                return NotFound();
            }

            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}