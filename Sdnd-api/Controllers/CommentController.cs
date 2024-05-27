using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Dtos.Responses;
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
        private readonly UserManager<User> _userManager;


        public CommentController(UserManager<User> userManager,AppDbContext context , IUserAccessor userAccessor)
        {
            _context = context;
            _userAccessor = userAccessor;
            _userManager = userManager;
        }

        // GET: api/Comment?documentId={documentId}
        // GET: api/Comment?documentId={documentId}
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CommentResponseDto>>> GetAllComments(Guid documentId)
        {
            // Fetch comments first
            var comments = await _context.Comments
                .Where(c => c.DocumentId == documentId)
                .ToListAsync();

            // Fetch user details
            var userIds = comments.Select(c => c.UserId).Distinct().ToList();
            var users = await _userManager.Users
                .Where(u => userIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id, u => u.UserName);

            // Map comments to DTOs with usernames
            var commentsDto = comments.Select(c => new CommentResponseDto
            {
                Id = c.Id,
                username = users.ContainsKey(c.UserId) ? users[c.UserId] : "Unknown User",
                commentText = c.CommentText,
                addedDate = c.AddedDate
            }).ToList();

            return Ok(commentsDto);
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
        public async Task<ActionResult<Comment>> CreateComment(AddCommentDto commentmodel)
        {
            var comment = new Comment
            {
                CommentText = commentmodel.Text,
                DocumentId = commentmodel.DocumentId,
                UserId = _userAccessor.GetCurrentUser().Id
            };
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