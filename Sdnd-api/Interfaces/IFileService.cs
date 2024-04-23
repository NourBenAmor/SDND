using Sdnd_Api.Models;


namespace Sdnd_api.Interfaces;
    
    public interface IFileService
    {
        public  Task<string> UploadFile(DocFile docFile,IFormFile file);
        
        public  Task<List<DocFile>> GetDocFilesByDocumentId(Guid documentId);
        
        public  Task<string> UpdateFile(IFormFile file);

    //public Task PostMultiFileAsync(List<FileUploadModel> fileData);



        //public Task PostMultiFileAsync(List<FileUploadModel> fileData);

    //public Task DownloadFileById(int fileName);
}
