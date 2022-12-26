using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using NhapHangV2.BaseAPI.Controllers;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.Services;
using NhapHangV2.Models;
using NhapHangV2.Request;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.API.Controllers
{
    [Route("api/admin-send-user-wallet")]
    [ApiController]
    [Description("Lịch sử nạp gần đây")]
    [Authorize]
    public class AdminSendUserWalletController : BaseController<AdminSendUserWallet, AdminSendUserWalletModel, AdminSendUserWalletRequest, AdminSendUserWalletSearch>
    {
        protected readonly IConfiguration configuration;
        protected readonly IAdminSendUserWalletService adminSendUserWalletService;
        protected readonly IUserService userService;
        public AdminSendUserWalletController(IServiceProvider serviceProvider, ILogger<BaseController<AdminSendUserWallet, AdminSendUserWalletModel, AdminSendUserWalletRequest, AdminSendUserWalletSearch>> logger, IWebHostEnvironment env, IConfiguration configuration) : base(serviceProvider, logger, env)
        {
            this.configuration = configuration;
            this.domainService = this.serviceProvider.GetRequiredService<IAdminSendUserWalletService>();
            adminSendUserWalletService = serviceProvider.GetRequiredService<IAdminSendUserWalletService>();
            userService = serviceProvider.GetRequiredService<IUserService>();
        }

        /// <summary>
        /// Xuất phiếu nạp tiền
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet("infor")]
        [AppAuthorize(new int[] { CoreContants.View })]
        public async Task<AppDomainResult> GetInforBill(int id)
        {
            var adminSendUserWallet = await adminSendUserWalletService.GetByIdAsync(id);
            if (adminSendUserWallet == null)
                throw new AppException("Yêu cầu không tồn tại");
            var inforBill = await adminSendUserWalletService.GetBillInforAsync(id);

            return new AppDomainResult
            {
                Data = inforBill,
                ResultCode = (int)HttpStatusCode.OK,
                Success = true
            };
        }

        /// <summary>
        /// Cập nhật trạng thái của lịch sử nạp (User)
        /// </summary>
        /// <param name="id"></param>
        /// <param name="status">2: Duyệt, 3: Hủy</param>
        /// <returns></returns>
        [HttpPut("update-status")]
        public async Task<AppDomainResult> UpdateStatus(int id, int status)
        {
            AppDomainResult appDomainResult = new AppDomainResult();

            var item = await this.domainService.GetByIdAsync(id);
            if (item == null)
                throw new KeyNotFoundException("Item không tồn tại");

            switch (status)
            {
                case (int)WalletStatus.DaDuyet:
                    break;
                case (int)WalletStatus.Huy:
                    if (item.Status != (int)WalletStatus.DangChoDuyet) //Muốn hủy thì trạng thái phải là Đang chờ duyệt
                        throw new AppException(string.Format("Lịch sử này bị sai trạng thái Hủy, vui lòng kiểm tra lại"));
                    break;
                default:
                    break;
            }

            bool success = false;
            success = await adminSendUserWalletService.UpdateStatus(item, status);
            if (success)
                appDomainResult.ResultCode = (int)HttpStatusCode.OK;
            else
                throw new Exception("Lỗi trong quá trình xử lý");
            appDomainResult.Success = success;
            return appDomainResult;
        }

        /// <summary>
        /// Thêm mới item
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPost]
        [AppAuthorize(new int[] { CoreContants.AddNew })]
        public override async Task<AppDomainResult> AddItem([FromBody] AdminSendUserWalletRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            if (ModelState.IsValid)
            {
                var item = mapper.Map<AdminSendUserWallet>(itemModel);
                if (item != null)
                {
                    // Kiểm tra item có tồn tại chưa?
                    var messageUserCheck = await this.domainService.GetExistItemMessage(item);
                    if (!string.IsNullOrEmpty(messageUserCheck))
                        throw new KeyNotFoundException(messageUserCheck);

                    success = await this.domainService.CreateAsync(item);
                    if (success)
                    {
                        appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                        appDomainResult.Data = item;
                    }

                    appDomainResult.Success = success;
                }
                else
                    throw new KeyNotFoundException("Item không tồn tại");
            }
            else
            {
                throw new AppException(ModelState.GetErrorMessage());
            }
            return appDomainResult;
        }

        /// <summary>
        /// Cập nhật thông tin item
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPut]
        [AppAuthorize(new int[] { CoreContants.Update })]
        public override async Task<AppDomainResult> UpdateItem([FromBody] AdminSendUserWalletRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            if (ModelState.IsValid)
            {
                var item = await this.domainService.GetByIdAsync(itemModel.Id);
                if (item != null)
                {
                    mapper.Map(itemModel, item);
                    // Kiểm tra item có tồn tại chưa?
                    var messageUserCheck = await this.domainService.GetExistItemMessage(item);
                    if (!string.IsNullOrEmpty(messageUserCheck))
                        throw new AppException(messageUserCheck);
                    success = await this.domainService.UpdateAsync(item);
                    if (success)
                        appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                    else
                        throw new Exception("Lỗi trong quá trình xử lý");
                    appDomainResult.Success = success;
                }
                else
                    throw new KeyNotFoundException("Item không tồn tại");
            }
            else
                throw new AppException(ModelState.GetErrorMessage());

            return appDomainResult;
        }

        #region Excel

        /// <summary>
        /// Xuất Excel
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        [HttpPost("export-excel")]
        public virtual async Task<AppDomainResult> ExportExcel([FromQuery] AdminSendUserWalletSearch baseSearch)
        {
            string fileResultPath = string.Empty;
            PagedList<AdminSendUserWalletModel> pagedListModel = new PagedList<AdminSendUserWalletModel>();
            // ------------------------------------------LẤY THÔNG TIN XUẤT EXCEL

            // 1. LẤY THÔNG TIN DATA VÀ ĐỔ DATA VÀO TEMPLATE
            PagedList<AdminSendUserWallet> pagedData = await this.domainService.GetPagedListData(baseSearch);
            pagedListModel = mapper.Map<PagedList<AdminSendUserWalletModel>>(pagedData);
            ExcelUtilities excelUtility = new ExcelUtilities();

            // 2. LẤY THÔNG TIN FILE TEMPLATE ĐỂ EXPORT
            string getTemplateFilePath = GetTemplateFilePath("AdminSendUserWalletTemplate.xlsx");
            excelUtility.TemplateFileData = System.IO.File.ReadAllBytes(getTemplateFilePath);

            // 3. LẤY THÔNG TIN THAM SỐ TRUYỀN VÀO
            excelUtility.ParameterData = await GetParameterReport(pagedListModel, baseSearch);
            if (pagedListModel.Items == null || !pagedListModel.Items.Any())
                pagedListModel.Items.Add(new AdminSendUserWalletModel());
            byte[] fileByteReport = excelUtility.Export(pagedListModel.Items);
            // Xuất biểu đồ nếu có
            fileByteReport = await this.ExportChart(fileByteReport, pagedListModel.Items);

            // 4. LƯU THÔNG TIN FILE BÁO CÁO XUỐNG FOLDER BÁO CÁO
            string fileName = string.Format("{0}-{1}.xlsx", Guid.NewGuid().ToString(), "AdminSendUserWallet");
            string filePath = Path.Combine(env.ContentRootPath, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.EXCEL_FOLDER_NAME, fileName);

            string folderUploadPath = string.Empty;
            var folderUpload = configuration.GetValue<string>("MySettings:FolderUpload");
            folderUploadPath = Path.Combine(folderUpload, CoreContants.UPLOAD_FOLDER_NAME, CoreContants.EXCEL_FOLDER_NAME);
            string fileUploadPath = Path.Combine(folderUploadPath, Path.GetFileName(filePath));

            FileUtilities.CreateDirectory(folderUploadPath);
            FileUtilities.SaveToPath(fileUploadPath, fileByteReport);

            var currentLinkSite = $"{Extensions.HttpContext.Current.Request.Scheme}://{Extensions.HttpContext.Current.Request.Host}/{CoreContants.EXCEL_FOLDER_NAME}/";
            fileResultPath = Path.Combine(currentLinkSite, Path.GetFileName(filePath));

            // 5. TRẢ ĐƯỜNG DẪN FILE CHO CLIENT DOWN VỀ
            return new AppDomainResult()
            {
                Data = fileResultPath,
                ResultCode = (int)HttpStatusCode.OK,
                Success = true,
            };
        }

        protected virtual async Task<byte[]> ExportChart(byte[] excelData, IList<AdminSendUserWalletModel> listData)
        {
            return excelData;
        }

        /// <summary>
        /// Lấy đường dẫn file template
        /// </summary>
        /// <param name="fileTemplateName"></param>
        /// <returns></returns>
        protected virtual string GetTemplateFilePath(string fileTemplateName)
        {
            var currentDirectory = System.IO.Directory.GetCurrentDirectory();
            string path = System.IO.Path.Combine(currentDirectory, CoreContants.TEMPLATE_FOLDER_NAME, fileTemplateName);
            if (!System.IO.File.Exists(path))
                throw new AppException("File template không tồn tại!");
            return path;
        }

        /// <summary>
        /// Lấy thông số parameter truyền vào
        /// </summary>
        /// <param name="pagedList"></param>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        protected virtual async Task<IDictionary<string, object>> GetParameterReport(PagedList<AdminSendUserWalletModel> pagedList, AdminSendUserWalletSearch baseSearch)
        {
            return await Task.Run(() =>
            {
                IDictionary<string, object> dictionaries = new Dictionary<string, object>();
                return dictionaries;
            });
        }

        #endregion
    }
}
