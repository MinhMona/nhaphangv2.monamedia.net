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
using NhapHangV2.Service.Services;
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
    [Route("api/withdraw")]
    [ApiController]
    [Description("Lịch sử nạp tệ")]
    [Authorize]
    public class WithdrawController : BaseController<Withdraw, WithdrawModel, WithdrawRequest, WithdrawSearch>
    {
        protected readonly IConfiguration configuration;
        protected readonly IWithdrawService withdrawService;
        protected readonly IUserService userService;
        public WithdrawController(IServiceProvider serviceProvider, ILogger<BaseController<Withdraw, WithdrawModel, WithdrawRequest, WithdrawSearch>> logger, IWebHostEnvironment env, IConfiguration configuration) : base(serviceProvider, logger, env)
        {
            this.configuration = configuration;
            this.domainService = this.serviceProvider.GetRequiredService<IWithdrawService>();
            withdrawService = serviceProvider.GetRequiredService<IWithdrawService>();
            userService = serviceProvider.GetRequiredService<IUserService>();
        }

        /// <summary>
        /// Cập nhật trạng thái của lịch sử nạp tệ (User)
        /// 2: Duyệt
        /// 3: Hủy
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPut("update-status")]
        public async Task<AppDomainResult> UpdateStatus([FromBody] WithdrawRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;

            var item = await this.domainService.GetByIdAsync(itemModel.Id);
            if (item == null)
                throw new KeyNotFoundException("Item không tồn tại");

            switch (itemModel.Status)
            {
                case (int)WalletStatus.DaDuyet: //Duyệt
                    if (item.Status != (int)WalletStatus.DangChoDuyet) //Muốn duyệt thì trạng thái phải là Đang chờ duyệt
                        throw new AppException(string.Format("Lịch sử này bị sai trạng thái Duyệt, vui lòng kiểm tra lại"));
                    break;
                case (int)WalletStatus.Huy: //Hủy
                    if (item.Status != (int)WalletStatus.DangChoDuyet) //Muốn hủy thì trạng thái phải là Đang chờ duyệt
                        throw new AppException(string.Format("Lịch sử này bị sai trạng thái Hủy, vui lòng kiểm tra lại"));
                    break;
                default:
                    break;
            }

            success = await withdrawService.UpdateStatus(item, itemModel.Status ?? 1);
            if (success)
                appDomainResult.ResultCode = (int)HttpStatusCode.OK;
            else
                throw new Exception("Lỗi trong quá trình xử lý");
            appDomainResult.Success = success;
            return appDomainResult;
        }

        /// <summary>
        /// Cập nhật thông tin item
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPut]
        [AppAuthorize(new int[] { CoreContants.Update })]
        public override async Task<AppDomainResult> UpdateItem([FromBody] WithdrawRequest itemModel)
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

        /// <summary>
        /// Xuất phiếu rút tiền
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet("infor")]
        [AppAuthorize(new int[] { CoreContants.View })]
        public async Task<AppDomainResult> GetInforBill(int id)
        {
            var withdraw = await withdrawService.GetByIdAsync(id);
            if (withdraw == null)
                throw new AppException("Yêu cầu không tồn tại");
            var inforBill = await withdrawService.GetBillInforAsync(id);

            return new AppDomainResult
            {
                Data = inforBill,
                ResultCode = (int)HttpStatusCode.OK,
                Success = true
            };
        }
        #region Excel

        /// <summary>
        /// Xuất Excel
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        [HttpPost("export-excel")]
        public virtual async Task<AppDomainResult> ExportExcel([FromQuery] WithdrawSearch baseSearch)
        {
            string fileResultPath = string.Empty;
            PagedList<WithdrawModel> pagedListModel = new PagedList<WithdrawModel>();
            // ------------------------------------------LẤY THÔNG TIN XUẤT EXCEL

            // 1. LẤY THÔNG TIN DATA VÀ ĐỔ DATA VÀO TEMPLATE
            PagedList<Withdraw> pagedData = await this.domainService.GetPagedListData(baseSearch);
            pagedListModel = mapper.Map<PagedList<WithdrawModel>>(pagedData);
            ExcelUtilities excelUtility = new ExcelUtilities();

            // 2. LẤY THÔNG TIN FILE TEMPLATE ĐỂ EXPORT
            string getTemplateFilePath = GetTemplateFilePath("WithdrawType2Template.xlsx");

            excelUtility.TemplateFileData = System.IO.File.ReadAllBytes(getTemplateFilePath);

            // 3. LẤY THÔNG TIN THAM SỐ TRUYỀN VÀO
            excelUtility.ParameterData = await GetParameterReport(pagedListModel, baseSearch);
            if (pagedListModel.Items == null || !pagedListModel.Items.Any())
                pagedListModel.Items.Add(new WithdrawModel());
            byte[] fileByteReport = excelUtility.Export(pagedListModel.Items);
            // Xuất biểu đồ nếu có
            fileByteReport = await this.ExportChart(fileByteReport, pagedListModel.Items);

            // 4. LƯU THÔNG TIN FILE BÁO CÁO XUỐNG FOLDER BÁO CÁO
            string fileName = string.Format("{0}-{1}.xlsx", Guid.NewGuid().ToString(), "Withdraw");
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

        protected virtual async Task<byte[]> ExportChart(byte[] excelData, IList<WithdrawModel> listData)
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
        protected virtual async Task<IDictionary<string, object>> GetParameterReport(PagedList<WithdrawModel> pagedList, WithdrawSearch baseSearch)
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
