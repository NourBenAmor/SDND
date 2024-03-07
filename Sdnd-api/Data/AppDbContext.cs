using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Models;
namespace Sdnd_api.Data;

public class AppDbContext : IdentityDbContext<User>
{
    public AppDbContext(DbContextOptions dbContextOptions) :base(dbContextOptions)
    {
    }
        public virtual DbSet<Document> Documents { get;  }
        public virtual DbSet<User> Users { get;  }
        public virtual DbSet<Annotation> Annotations { get;  }
        public virtual DbSet<SharedDocument> SharedDocuments { get;  }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            List<IdentityRole> roles = new List<IdentityRole>
            {
                new IdentityRole()
                {
                    Name = "Admin",
                    NormalizedName = "ADMIN"
                },
                new IdentityRole()
                {
                    Name = "User",
                    NormalizedName = "USER"
                }
            };
            builder.Entity<IdentityRole>().HasData(roles);
            builder.Entity<Document>()
                .HasOne(d => d.Owner)
                .WithMany(u => u.Documents)
                .HasForeignKey(p => p.ownerId);
        }
        
}