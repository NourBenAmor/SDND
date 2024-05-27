using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Sdnd_api.Data;
using Sdnd_api.Dtos.Requests;
using Sdnd_api.Interfaces;
using Sdnd_api.Models;
using Sdnd_Api.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using iText.Bouncycastle.Cert;
using iText.Bouncycastle.X509;
using iText.Bouncycastle.Crypto;
using iText.Commons.Bouncycastle.Cert;
using iText.Commons.Bouncycastle.Crypto;
using iText.Forms.Form.Element;
using iText.IO.Image;
using iText.Kernel.Geom;
using iText.Kernel.Pdf;
using iText.Signatures;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Pkcs;
using Org.BouncyCastle.X509;
using Path = System.IO.Path;

[Route("api/[controller]")]
[ApiController]
public class AnnotationController : ControllerBase
{
    
    private readonly AppDbContext _context;
    private readonly IFileService _fileService;
    private readonly IUserAccessor _userAccessor;
    public AnnotationController(AppDbContext context, IUserAccessor userAccessor,IFileService fileService)
    {
        _context = context;
        _userAccessor = userAccessor;
        _fileService = fileService;
    }
    [HttpPost("TestSignature")]
    public async Task<IActionResult> Sign()
    {
        //SignatureExample signatureExample = new SignatureExample();
        //signatureExample.TestSignatureExample();
        return Ok("Succeded");
    }
    
    [HttpPost("NewVersion")] 
    public async Task<IActionResult> MakeSignature([FromForm] SignatureRequestDto model)
        {
            var folderName = Path.Combine("Resource", "AllFiles");
            var pathToSave = Path.Combine(Directory.GetCurrentDirectory(), folderName);
            var LastVersionFileName = model.FileId.ToString();
            // Use a regular expression to remove any existing version number from the filename
            var fileName = Regex.Replace(model.FileId.ToString(), @"_\\d+$", "");
            var user = await _context.Users.FindAsync(_userAccessor.GetCurrentUser().Id);
            var fileModel = await _context.DocFiles.FirstOrDefaultAsync(f => f.Id == Guid.Parse(fileName));
            var Document = await _context.Documents.FindAsync(fileModel?.DocumentId);
            if (user?.Id != Document?.OwnerId && !await _context.SharedDocuments.AnyAsync(d =>
                    d.DocumentId == Document.Id && d.SharedWithUserId == user.Id && d.Permissions.Any(p => p.Name == "edit")))
                return Unauthorized("You are not authorized to update this document");
            // Get all files that start with the same FileId
            var files = Directory.GetFiles(pathToSave, $"{fileName}");

            // Extract version numbers from filenames
            var versionNumbers = files.Select(file =>
            {
                var versionString = Path.GetFileNameWithoutExtension(file).Replace(fileName, "").Replace("_*", "");
                int version;
                return int.TryParse(versionString, out version) ? version : 0;
            });

            // Determine the new version number
            var newVersionNumber = versionNumbers.Any() ? versionNumbers.Max() + 1 : 1;
            
            var fullPath = Path.Combine(pathToSave, fileName + "_" + (newVersionNumber - 1));
            // Append the version number to the filename 
            var fullNewPath = Path.Combine(pathToSave, $"{fileName}_{newVersionNumber}");

            SignatureExample signatureExample = new SignatureExample();
            signatureExample.TestSignatureExample(fullNewPath, fullPath, model.SignatureImg, model.PageNumber,newVersionNumber);
            return Ok($"{fileName}_{newVersionNumber},newVersionNumber");
        }
   

public class SignatureExample
    {
        public static readonly String CERT_NAME = "signCertRsa01.p12";
        public static readonly String Folder_Path = Path.Combine(Directory.GetCurrentDirectory(), "Resource");
        public static readonly String CERT_PATH = Path.Combine(Folder_Path, CERT_NAME);
        public void TestSignatureExample(string dest,string src,string imageString,int pageNumber,int signatureNumber)
        {
            FileInfo file = new FileInfo(dest);
            file.Directory.Create();

            new SignatureExample().ManipulatePdf(dest,src,imageString,pageNumber,signatureNumber);
        }

        
        protected void ManipulatePdf(string dest,string src,string imageString,int pageNumber ,int signatureNumber)
        {
            ElectronicSignatureInfoDTO signatureInfo = new ElectronicSignatureInfoDTO();
            signatureInfo.Bottom = 25;
            signatureInfo.Left = 25;
            signatureInfo.PageNumber = pageNumber;
            SignDocumentSignature(dest, signatureInfo,src, imageString, signatureNumber);
        }
    
        
        protected void SignDocumentSignature(string filePath, ElectronicSignatureInfoDTO signatureInfo, string src, string imageString, int signatureNumber)
        {
                // Check if the source file exists
                if (!System.IO.File.Exists(src))
                {
                    throw new FileNotFoundException($"The source PDF file was not found at: {src}");
                }

                // Attempt to open the PDF file to check if it's a valid PDF
                try
                {
                    using (var reader = new PdfReader(src))
                    {
                        // If this point is reached, the file is a valid PDF
                    }
                }
                catch (iText.IO.Exceptions.IOException ex)
                {
                    throw new Exception($"Failed to open the PDF file at {src}. It may not be a valid PDF or could be corrupted.", ex);
                }

                // Proceed with the signing process as before
             
            PdfDocument pdfDoc = new PdfDocument(new PdfReader(src));
            Rectangle pageSize = pdfDoc.GetFirstPage().GetPageSize();
            PdfSigner pdfSigner = new PdfSigner(new PdfReader(src), new FileStream(filePath, FileMode.Create),
                new StampingProperties());

            // Set the name indicating the field to be signed.
            // The field can already be present in the document but shall not be signed
            string signatureFieldName = "signature" + signatureNumber;
            pdfSigner.SetFieldName(signatureFieldName);

            byte[] imageBytes = Convert.FromBase64String(imageString);
            ImageData clientSignatureImage = ImageDataFactory.Create(imageBytes);

            SignatureFieldAppearance appearance = new SignatureFieldAppearance(pdfSigner.GetFieldName())
                .SetContent(clientSignatureImage);
            pdfSigner.SetPageNumber(signatureInfo.PageNumber)
                .SetPageRect(new Rectangle(0, 0, pageSize.GetWidth(), pageSize.GetHeight()))
                .SetSignatureAppearance(appearance);

            char[] password = "testpass".ToCharArray();
            IExternalSignature pks = GetPrivateKeySignature(CERT_PATH, password);
            IX509Certificate[] chain = GetCertificateChain(CERT_PATH, password);
            OCSPVerifier ocspVerifier = new OCSPVerifier(null, null);
            OcspClientBouncyCastle ocspClient = new OcspClientBouncyCastle(ocspVerifier);
            List<ICrlClient> crlClients = new List<ICrlClient>(new[] {new CrlClientOnline()});

            // Sign the document using the detached mode, CMS or CAdES equivalent.
            // This method closes the underlying pdf document, so the instance
            // of PdfSigner cannot be used after this method call
            pdfSigner.SignDetached(pks, chain, crlClients, ocspClient, null, 0,
                PdfSigner.CryptoStandard.CMS);
        }
        /// Method reads pkcs12 file's first private key and returns a
        /// <see cref="PrivateKeySignature"/> instance, which uses SHA-512 hash algorithm. 
        private PrivateKeySignature GetPrivateKeySignature(String certificatePath, char[] password)
        {
            String alias = null;
            Pkcs12Store pk12 = new Pkcs12StoreBuilder().Build();
            pk12.Load(new FileStream(certificatePath, FileMode.Open, FileAccess.Read), password);

            foreach (var a in pk12.Aliases)
            {
                alias = ((String) a);
                if (pk12.IsKeyEntry(alias))
                {
                    break;
                }
            }

            IPrivateKey pk = new PrivateKeyBC(pk12.GetKey(alias).Key);
            return new PrivateKeySignature(pk, DigestAlgorithms.SHA512);
        }

        /// Method reads first public certificate chain
        private IX509Certificate[] GetCertificateChain(String certificatePath, char[] password)
        {
            IX509Certificate[] chain;
            String alias = null;
            Pkcs12Store pk12 = new Pkcs12StoreBuilder().Build();
            pk12.Load(new FileStream(certificatePath, FileMode.Open, FileAccess.Read), password);

            foreach (var a in pk12.Aliases)
            {
                alias = ((String) a);
                if (pk12.IsKeyEntry(alias))
                {
                    break;
                }
            }

            X509CertificateEntry[] ce = pk12.GetCertificateChain(alias);
            chain = new IX509Certificate[ce.Length];
            for (int k = 0; k < ce.Length; ++k)
            {
                chain[k] = new X509CertificateBC(ce[k].Certificate);
            }

            return chain;
        }

        protected class ElectronicSignatureInfoDTO
        {
            public int PageNumber { get; set; }

            public float Left { get; set; }

            public float Bottom { get; set; }
        }
    }

}