using Sdnd_api.Models;

namespace Sdnd_Api.Models;

public class DocFile : BaseEntity
{
    public string Name { get; set; }
    public string Context { get; set; } = string.Empty;
    public string OcrText { get; set; } = string.Empty;
    public long FileSize { get; set; } // Changed to long for larger file sizes
    public string FormattedFileSize => FormatFileSize(FileSize);
    public string FilePath { get; set; } = "";
    public FileStatus FileStatus { get; set; } = FileStatus.Uploaded; // Changed enum name to FileStatus
    public Guid DocumentId { get; set; }

    private string FormatFileSize(long fileSize)
    {
        string[] sizes = { "B", "KB", "MB", "GB", "TB" };
        double len = fileSize;
        int order = 0;
        while (len >= 1024 && order < sizes.Length - 1)
        {
            order++;
            len /= 1024;
        }

        return $"{len:0.##} {sizes[order]}";
    }
}

public enum FileStatus // Changed enum name to PascalCase
{
    Uploaded,
    TextExtracted,
    Archived
}