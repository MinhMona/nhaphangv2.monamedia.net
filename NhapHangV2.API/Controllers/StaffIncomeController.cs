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

namespace NhapHangV2.API.Controllers
{
    [Route("api/staff-income")]
    [ApiController]
    [Description("Quản lý hoa hồng")]
    [Authorize]
    public class StaffIncomeController : BaseController<StaffIncome, StaffIncomeModel, StaffIncomeRequest, StaffIncomeSearch>
    {
        protected readonly IStaffIncomeService staffIncomeService;
        private IConfiguration configuration;
        public StaffIncomeController(IServiceProvider serviceProvider, ILogger<BaseController<StaffIncome, StaffIncomeModel, StaffIncomeRequest, StaffIncomeSearch>> logger, IWebHostEnvironment env, IConfiguration configuration) : base(serviceProvider, logger, env)
        {
            this.configuration = configuration;
            this.domainService = this.serviceProvider.GetRequiredService<IStaffIncomeService>();
            staffIncomeService = serviceProvider.GetRequiredService<IStaffIncomeService>();
        }

        /// <summary>
        /// Thanh toán hoa hồng 
        /// </summary>        
        /// <param name="type">1: Thanh toán theo Id (1 thằng), 2: Thanh toán tất cả (nhiều thằng)</param>
        /// <param name="id">Thanh toán 1 Id</param>
        /// <param name="baseSearch">Thanh toán tất cả dựa trên baseSearch (PageIndex = 0, PageSize = 0)</param>
        /// <returns></returns>
        [HttpPut("payment")]
        [AppAuthorize(new int[] { CoreContants.Update })]
        public async Task<AppDomainResult> CommissionPayment(int type, int id)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            List<StaffIncome> staffIncomes = new List<StaffIncome>();
            switch (type)
            {
                case 1: //Thanh toán theo ID
                    var staffIncome = await staffIncomeService.GetByIdAsync(id);
                    if (staffIncome == null)
                        throw new KeyNotFoundException("Item không tồn tại");
                    staffIncomes.Add(staffIncome);
                    break;
                case 2: //Thanh toán tất cả dựa trên baseSearch
                    StaffIncomeSearch baseSearch = new StaffIncomeSearch { Status = 1 };
                    PagedList<StaffIncome> pagedData = await this.domainService.GetPagedListData(baseSearch);
                    if (!pagedData.Items.Any())
                        throw new KeyNotFoundException("List item không tồn tại");
                    staffIncomes.AddRange(pagedData.Items);
                    break;
                default:
                    throw new KeyNotFoundException("Lỗi không tìm thấy loại thanh toán");
            }

            success = await staffIncomeService.UpdateStatus(staffIncomes);
            if (success)
                appDomainResult.ResultCode = (int)HttpStatusCode.OK;
            else
                throw new Exception("Lỗi trong quá trình xử lý");

            appDomainResult.Success = success;
            return appDomainResult;
        }

        #region Excel

        /// <summary>
        /// Xuất Excel
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        [HttpPost("export-excel")]
        public virtual async Task<AppDomainResult> ExportExcel([FromQuery] StaffIncomeSearch baseSearch)
        {
            string fileResultPath = string.Empty;
            PagedList<StaffIncomeModel> pagedListModel = new PagedList<StaffIncomeModel>();
            // ------------------------------------------LẤY THÔNG TIN XUẤT EXCEL

            // 1. LẤY THÔNG TIN DATA VÀ ĐỔ DATA VÀO TEMPLATE
            PagedList<StaffIncome> pagedData = await this.domainService.GetPagedListData(baseSearch);
            pagedListModel = mapper.Map<PagedList<StaffIncomeModel>>(pagedData);
            ExcelUtilities excelUtility = new ExcelUtilities();

            // 2. LẤY THÔNG TIN FILE TEMPLATE ĐỂ EXPORT
            excelUtility.TemplateFileData = System.IO.File.ReadAllBytes(GetTemplateFilePath("StaffIncomeTemplate.xlsx"));

            // 3. LẤY THÔNG TIN THAM SỐ TRUYỀN VÀO
            excelUtility.ParameterData = await GetParameterReport(pagedListModel, baseSearch);
            if (pagedListModel.Items == null || !pagedListModel.Items.Any())
                pagedListModel.Items.Add(new StaffIncomeModel());
            byte[] fileByteReport = excelUtility.Export(pagedListModel.Items);
            // Xuất biểu đồ nếu có
            fileByteReport = await this.ExportChart(fileByteReport, pagedListModel.Items);

            // 4. LƯU THÔNG TIN FILE BÁO CÁO XUỐNG FOLDER BÁO CÁO
            string fileName = string.Format("{0}-{1}.xlsx", Guid.NewGuid().ToString(), "StaffIncome");
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

        protected virtual async Task<byte[]> ExportChart(byte[] excelData, IList<StaffIncomeModel> listData)
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
        protected virtual async Task<IDictionary<string, object>> GetParameterReport(PagedList<StaffIncomeModel> pagedList, StaffIncomeSearch baseSearch)
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
