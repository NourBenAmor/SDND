using Microsoft.EntityFrameworkCore;
using Sdnd_api.Data;
using Sdnd_api.Interfaces;
using Sdnd_Api.Models;

namespace FileUpload.Services
{
    public class FileService : IFileService
    {
        private readonly AppDbContext _context;
        public FileService(AppDbContext context)
        {
            _context = context;
        }
        public async Task<string> UploadFile(DocFile docFile, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return "File not selected";
            }

            var folderName = Path.Combine("Resource", "AllFiles");
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);
            if (!Directory.Exists(pathToSave))
                Directory.CreateDirectory(pathToSave);
            var fileName = docFile.Id.ToString()+"_0";
            var fullPath = Path.Combine(pathToSave, fileName);
            var dbPath = Path.Combine(folderName, fileName);

            if (System.IO.File.Exists(fullPath))
                return "file Already Exists";

            await using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }
            return dbPath;
        }
        public async Task<List<DocFile>> GetDocFilesByDocumentId(Guid documentId)
        {
            var docFiles = _context.DocFiles
                .Where(x => x.DocumentId == documentId)
                .ToList();
            return docFiles;
        }

        public async Task<string> UpdateFile(IFormFile file)
        {
            if (file == null && file.Length == 0)
            {
                return "file not selected";
            }

            var folderName = Path.Combine("Resource", "AllFiles");
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);
            if (!Directory.Exists(pathToSave))
                Directory.CreateDirectory(pathToSave);
            var fileName = file.Name;
            var fullPath = Path.Combine(pathToSave, fileName);
            var dbPath = Path.Combine(folderName, fileName);

            if (System.IO.File.Exists(fullPath))
                return "file Already Exists";

            await using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return dbPath;
        }

        /*public async Task PostMultiFileAsync(List<FileUploadModel> fileData)
        {
            try
            {
                foreach(FileUploadModel file in fileData)
                {
                    var fileDetails = new FileDetails()
                    {
                        ID = 0,
                        FileName = file.FileDetails.FileName,
                        FileType = file.FileType,
                    };

                    using (var stream = new MemoryStream())
                    {
                        file.FileDetails.CopyTo(stream);
                        fileDetails.FileData = stream.ToArray();
                    }

                    var result = dbContextClass.FileDetails.Add(fileDetails);
                }
                await dbContextClass.SaveChangesAsync();
            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task DownloadFileById(int Id)
        {
            try
            {
                var file =  dbContextClass.FileDetails.Where(x => x.ID == Id).FirstOrDefaultAsync();

                var content = new System.IO.MemoryStream(file.Result.FileData);
                var path = Path.Combine(
                   Directory.GetCurrentDirectory(), "FileDownloaded",
                   file.Result.FileName);

                await CopyStream(content, path);
            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task CopyStream(Stream stream, string downloadPath)
        {
            using (var fileStream = new FileStream(downloadPath, FileMode.Create, FileAccess.Write))
            {
               await stream.CopyToAsync(fileStream);
            }
        }*/

        
        // M�thode pour supprimer physiquement un fichier � partir de son chemin
       
    }

}


