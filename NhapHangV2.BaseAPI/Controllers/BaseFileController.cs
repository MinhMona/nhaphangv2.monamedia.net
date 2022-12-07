using AutoMapper;
using NhapHangV2.Extensions;
using NhapHangV2.Utilities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.WebUtilities;
using System.Net.Http;
using NPOI.HPSF;
using System.Diagnostics;
using RestSharp.Extensions;
using System.Net;
using System.Web.Http;
using System.ServiceModel;
using System.Net.Http.Headers;
using Microsoft.Net.Http.Headers;
using NhapHangV2.Interface.Services;
using ContentDispositionHeaderValue = System.Net.Http.Headers.ContentDispositionHeaderValue;
using MediaTypeHeaderValue = Microsoft.Net.Http.Headers.MediaTypeHeaderValue;

namespace NhapHangV2.BaseAPI.Controllers
{
    [ApiController]
    public abstract class BaseFileController : ControllerBase
    {
        protected readonly IServiceProvider serviceProvider;
        protected readonly ILogger<ControllerBase> logger;
        protected readonly IWebHostEnvironment env;
        protected readonly IMapper mapper;
        protected readonly IConfiguration configuration;
        public BaseFileController(IServiceProvider serviceProvider, ILogger<ControllerBase> logger, IWebHostEnvironment env, IMapper mapper, IConfiguration configuration)
        {
            this.serviceProvider = serviceProvider;
            this.logger = logger;
            this.env = env;
            this.mapper = mapper;
            this.configuration = configuration;
        }

        /// <summary>
        /// Upload Single File
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost("upload-file")]
        [AppAuthorize(new int[] { CoreContants.Upload })]
        public virtual async Task<AppDomainResult> UploadFile(IFormFile file)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            await Task.Run(() =>
            {
                if (file != null && file.Length > 0)
                {
                    string fileName = string.Format("{0}-{1}", Guid.NewGuid().ToString(), file.FileName);

                    string fileUploadPath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME);
                    string path = Path.Combine(fileUploadPath, fileName);
                    FileUtilities.CreateDirectory(fileUploadPath);
                    var fileByte = FileUtilities.StreamToByte(file.OpenReadStream());
                    FileUtilities.SaveToPath(path, fileByte);

                    string filePath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME, fileName);
                    string folderUploadPath = string.Empty;
                    var folderUpload = configuration.GetValue<string>("MySettings:FolderUpload");
                    folderUploadPath = Path.Combine(folderUpload, CoreContants.UPLOAD_FOLDER_NAME); //Có thể add tên thư mục vào đây để có thể đưa hình vào thư mục đó
                    string fileUploadPath2 = Path.Combine(folderUploadPath, Path.GetFileName(filePath));

                    string fileUrl = "";
                    // Kiểm tra có tồn tại file trong temp chưa?
                    if (System.IO.File.Exists(filePath) && !System.IO.File.Exists(fileUploadPath2))
                    {
                        FileUtilities.CreateDirectory(folderUploadPath);
                        FileUtilities.SaveToPath(fileUploadPath2, System.IO.File.ReadAllBytes(filePath));
                        var currentLinkSite = $"{Extensions.HttpContext.Current.Request.Scheme}://{Extensions.HttpContext.Current.Request.Host}/{CoreContants.UPLOAD_FOLDER_NAME}/";
                        fileUrl = Path.Combine(currentLinkSite, Path.GetFileName(filePath)); //Có thể add tên thư mục vào đây để có thể đưa hình vào thư mục đó
                                                                                             // ------- END GET URL FOR FILE
                    }
                    System.IO.File.Delete(filePath);
                    appDomainResult = new AppDomainResult()
                    {
                        Success = true,
                        Data = fileUrl
                    };
                }
            });
            return appDomainResult;
        }

        /// <summary>
        /// Upload Multiple File
        /// </summary>
        /// <param name="files"></param>
        /// <returns></returns>
        [HttpPost("upload-multiple-files")]
        [AppAuthorize(new int[] { CoreContants.Upload })]
        public virtual async Task<AppDomainResult> UploadFiles(List<IFormFile> files)
        {
            AppDomainResult appDomainResult = new AppDomainResult();

            await Task.Run(() =>
            {
                if (files != null && files.Any())
                {
                    List<string> fileUrls = new List<string>();
                    foreach (var file in files)
                    {
                        string fileName = string.Format("{0}-{1}", Guid.NewGuid().ToString(), file.FileName);
                        string fileUploadPath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME);
                        string path = Path.Combine(fileUploadPath, fileName);
                        FileUtilities.CreateDirectory(fileUploadPath);
                        var fileByte = FileUtilities.StreamToByte(file.OpenReadStream());
                        FileUtilities.SaveToPath(path, fileByte);

                        string filePath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME, fileName);
                        string folderUploadPath = string.Empty;
                        var folderUpload = configuration.GetValue<string>("MySettings:FolderUpload");
                        folderUploadPath = Path.Combine(folderUpload, CoreContants.UPLOAD_FOLDER_NAME); //Có thể add tên thư mục vào đây để có thể đưa hình vào thư mục đó
                        string fileUploadPath2 = Path.Combine(folderUploadPath, Path.GetFileName(filePath));

                        string fileUrl = "";
                        // Kiểm tra có tồn tại file trong temp chưa?
                        if (System.IO.File.Exists(filePath) && !System.IO.File.Exists(fileUploadPath2))
                        {
                            FileUtilities.CreateDirectory(folderUploadPath);
                            FileUtilities.SaveToPath(fileUploadPath2, System.IO.File.ReadAllBytes(filePath));
                            var currentLinkSite = $"{Extensions.HttpContext.Current.Request.Scheme}://{Extensions.HttpContext.Current.Request.Host}/{CoreContants.UPLOAD_FOLDER_NAME}/";
                            fileUrl = Path.Combine(currentLinkSite, Path.GetFileName(filePath)); //Có thể add tên thư mục vào đây để có thể đưa hình vào thư mục đó
                                                                                                 // ------- END GET URL FOR FILE
                        }
                        System.IO.File.Delete(filePath);

                        fileUrls.Add(fileUrl);
                    }
                    appDomainResult = new AppDomainResult()
                    {
                        Success = true,
                        Data = fileUrls
                    };
                }
            });
            return appDomainResult;
        }


        [DisableFormValueModelBinding]
        [RequestSizeLimit(long.MaxValue)]
        [RequestFormLimits(MultipartBodyLengthLimit = long.MaxValue)]
        [HttpPost("upload-file-stream")]
        [AppAuthorize(new int[] { CoreContants.Upload })]
        public virtual async Task<AppDomainResult> UploadFileStream([FromQuery] string fileName, [FromQuery] int part, [FromQuery] int size)
         {
            AppDomainResult appDomainResult = new AppDomainResult();
            await Task.Run(async () =>
            {
                Request.EnableBuffering(long.MaxValue);
                var content = new StreamContent(Request.BodyReader.AsStream(true));
                foreach (var header in Request.Headers)
                {
                    content.Headers.TryAddWithoutValidation(header.Key, header.Value.AsEnumerable());
                }
                if (!string.IsNullOrEmpty(fileName.Trim()) && part > 0 && size >= part && content.Headers.ContentLength > 0)
                {
                    string fileUploadPath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME);
                    var provider = new MultipartFormDataStreamProvider(fileUploadPath);
                    string originalFileName = String.Concat(fileUploadPath, "\\" + fileName.Replace('.', '_') + "_" + part);
                    FileStream fileInput = new FileStream(originalFileName, FileMode.Create);
                    await content.CopyToAsync(fileInput);
                    fileInput.Close();
                    string doneFileName = String.Concat(fileUploadPath, "\\" + fileName.Replace('.', '_') + "_Done_" + part);
                    System.IO.File.Move(originalFileName, doneFileName);
                    string[] filePaths = Directory.GetFiles(fileUploadPath, fileName.Replace('.', '_')+"_Done" + "*");
                    if (filePaths.Length >= size)
                    {
                        var resultFile = System.IO.File.Create(fileUploadPath + "\\" + fileName);
                        resultFile.Position = 0;
                        string[] filePathsOrded = new string[filePaths.Length + 1];
                        foreach (var filePath in filePaths)
                        {
                            int startIndex = filePath.LastIndexOf("_") + 1;
                            int partFile = int.Parse(filePath.Substring(startIndex));
                            filePathsOrded[partFile] = filePath;
                        }
                        for (int i = 1; i < filePathsOrded.Length; i++)
                        {
                            var data = System.IO.File.ReadAllBytes(filePathsOrded[i]);
                            foreach (var x in data)
                            {
                                resultFile.WriteByte(x);
                            }
                            System.IO.File.Delete(filePathsOrded[i]);
                        }
                        resultFile.Close();

                    }
                    appDomainResult = new AppDomainResult()
                    {
                        Success = true
                    };
                }
            });
            return appDomainResult;
         }


        [HttpGet("download-file")]
        [AppAuthorize(new int[] { CoreContants.Upload })]
        public virtual async Task<PhysicalFileResult> DownloadFile([FromQuery] string fileName)
        {
            string fileUploadPath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.TEMP_FOLDER_NAME);
            var filePath = fileUploadPath + "\\" + fileName;
            var resultFile = new PhysicalFileResult(filePath, "application/octet-stream")
            {
                FileDownloadName = fileName,
            };
            return resultFile;
        }

    } 




}
