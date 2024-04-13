using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Sdnd_api.Models;
using System;
using System.Collections.Generic;

namespace Sdnd_api.Data
{
    public class AppDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid>
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public virtual DbSet<Document> Documents { get; set; }
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Annotation> Annotations { get; set; }
        public virtual DbSet<SharedDocument> SharedDocuments { get; set; }
        public virtual DbSet<Models.File> Files { get; set; }

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
            });

            builder.Entity<Document>(entity =>
            {
                entity.HasMany<Annotation>()
                    .WithOne()
                    .HasForeignKey(e => e.documentId)
                    .OnDelete(DeleteBehavior.NoAction);
                entity.HasMany<SharedDocument>()
                    .WithOne()
                    .HasForeignKey(e => e.DocumentId)
                    .OnDelete(DeleteBehavior.SetNull);
            });

            builder.Entity<Models.File>(entity =>
            {
                entity.HasOne(f => f.Document)
                    .WithMany(d => d.Files)
                    .HasForeignKey(f => f.DocumentId)
                    .OnDelete(DeleteBehavior.SetNull);
            });

            builder.Entity<SharedDocument>()
                .HasOne<Document>()
                .WithMany()
                .HasForeignKey(sd => sd.DocumentId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}
