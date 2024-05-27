using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Models;
using Sdnd_Api.Models;
using System.Reflection.Emit;

namespace Sdnd_api.Data
{
    public class AppDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid>
    {
        public AppDbContext(DbContextOptions options) : base(options)
        {
        }

        public virtual DbSet<Document> Documents { get; set; }
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Annotation> Annotations { get; set; }
        public virtual DbSet<SharedDocument> SharedDocuments { get; set; }
        public virtual DbSet<DocFile> DocFiles { get; set; }

        public virtual DbSet<SharingPermission> SharingPermissions { get; set; }
        public virtual DbSet<Comment> Comments { get; set; }
        public virtual DbSet<DocTask> DocTasks { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            List<IdentityRole<Guid>> roles = new List<IdentityRole<Guid>>
            {
                new IdentityRole<Guid>()
                {
                    Id = new Guid("f1f57e4f-616c-4422-8b83-5b6f5ca2915a"),
                    Name = "Admin",
                    NormalizedName = "ADMIN"
                },
                new IdentityRole<Guid>()
                {
                    Id = new Guid("88dc1abe-9a49-4af9-b667-4454a6bf16c3"),
                    Name = "User",
                    NormalizedName = "USER"
                }
            };
            builder.Entity<IdentityRole<Guid>>().HasData(roles);

            builder.Entity<User>(entity =>
            {
                entity.HasMany<Document>()
                    .WithOne()
                    .HasForeignKey(e => e.OwnerId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<SharedDocument>()
                    .WithOne()
                    .HasForeignKey(e => e.SharedWithUserId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<Annotation>()
                    .WithOne()
                    .HasForeignKey(e => e.userId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<Comment>()
                    .WithOne()
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
                entity.HasMany<DocTask>()
                    .WithOne()
                    .HasForeignKey(e => e.AssignedUserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            builder.Entity<Document>(entity =>
            {

                entity.HasMany<Annotation>()
                    .WithOne()
                    .HasForeignKey(e => e.documentId)
                    .OnDelete(DeleteBehavior.Restrict);
                entity.HasMany<SharedDocument>()
                    .WithOne()
                    .HasForeignKey(e => e.DocumentId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<DocFile>()
                    .WithOne()
                    .HasForeignKey(e => e.DocumentId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<Comment>()
                    .WithOne()
                    .HasForeignKey(e => e.DocumentId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<DocTask>()
                    .WithOne()
                    .HasForeignKey(e => e.SharedDocumentId)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasMany<SharedDocument>()
            .WithOne()
            .HasForeignKey(e => e.DocumentId)
            .OnDelete(DeleteBehavior.Cascade);

            }
            );
            // Create password hasher
            var hasher = new PasswordHasher<User>();

            // Create default user
            var defaultUser = new User
            {
                Id = Guid.NewGuid(),
                UserName = "admin",
                NormalizedUserName = "ADMIN",
                Email = "admin@example.com",
                NormalizedEmail = "ADMIN@EXAMPLE.COM",
                EmailConfirmed = true,
                SecurityStamp = string.Empty,
            };

            // Hash the password and assign it to the user
            defaultUser.PasswordHash = hasher.HashPassword(defaultUser, "Admin123!");

            // Add the user to the Users table
            builder.Entity<User>().HasData(defaultUser);

            // Assign the admin role to the user
            builder.Entity<IdentityUserRole<Guid>>().HasData(new IdentityUserRole<Guid>
            {
                RoleId = new Guid("f1f57e4f-616c-4422-8b83-5b6f5ca2915a"), // Admin role ID
                UserId = defaultUser.Id
            });
            List<SharingPermission> SharingPermissions = new List<SharingPermission>
            {
                new SharingPermission(){Id = 1, Name = "view"},
               new SharingPermission(){Id = 2, Name = "edit"},
               new SharingPermission(){ Id = 3, Name = "share"},
            };
            builder.Entity<SharingPermission>().HasData(SharingPermissions);
            builder.Entity<SharedDocument>()
                .HasMany(s => s.Permissions)
                .WithMany();
        }
    }
}