using NhapHangV2.Entities;
using NhapHangV2.Entities.DomainEntities;
using NhapHangV2.Interface.UnitOfWork;
using NhapHangV2.Service;
using NhapHangV2.Utilities;
using AutoMapper;
using Ganss.Excel;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using NhapHangV2.Interface.Services.DomainServices;
using NhapHangV2.Entities.ExcelMapper;

namespace NhapHangV2.Service.Services.DomainServices
{
    public abstract class CatalogueService<E, T> : DomainService<E, T>, ICatalogueService<E, T> where E : AppDomainCatalogue, new() where T : CatalogueSearch, new()
    {
        protected IConfiguration configuration;
        public bool IsUseStore = false;
        public CatalogueService(IUnitOfWork unitOfWork, IMapper mapper, IConfiguration configuration) : base(unitOfWork, mapper)
        {
            this.configuration = configuration;
        }

        public CatalogueService(IUnitOfWork unitOfWork, IMapper mapper) : base(unitOfWork, mapper)
        {
        }

        public override async Task<bool> SaveAsync(E item)
        {
            var existCode = unitOfWork.CatalogueRepository<E>().GetQueryable()
                .AsNoTracking()
                .Where(e =>
                e.Code == item.Code
                && !e.Deleted)
                .FirstOrDefault();

            if (existCode != null && item.Id != existCode.Id)
            {
                throw new Exception("Mã đã tồn tại");
            }

            var exists = unitOfWork.CatalogueRepository<E>().GetQueryable()
                .AsNoTracking()
                .Where(e =>
                e.Id == item.Id
                && !e.Deleted)
                .FirstOrDefault();
            if (exists != null)
            {
                exists = mapper.Map<E>(item);
                unitOfWork.CatalogueRepository<E>().Update(exists);
            }
            else
            {
                await unitOfWork.CatalogueRepository<E>().CreateAsync(item);

            }
            await unitOfWork.SaveAsync();
            return true;

        }

        /// <summary>
        /// Lấy item theo mã
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        public virtual E GetByCode(string code)
        {
            return unitOfWork.CatalogueRepository<E>()
                .GetQueryable()
                .Where(e => e.Code == code && !e.Deleted)
                .FirstOrDefault();
        }

        /// <summary>
        /// Lấy item theo mã
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        public virtual async Task<E> GetByCodeAsync(string code)
        {
            return await Queryable.Where(e => e.Code == code && !e.Deleted).AsNoTracking().FirstOrDefaultAsync();
        }

        /// <summary>
        /// Check trùng mã
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public override async Task<string> GetExistItemMessage(E item)
        {
            string result = string.Empty;
            bool isExistCode = await this.Queryable.AnyAsync(x => !x.Deleted && x.Id != item.Id && x.Code == item.Code);
            if (isExistCode)
                return "Mã đã tồn tại!";
            return result;
        }

        /// <summary>
        /// Lấy danh sách phân trang danh mục
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        public override async Task<PagedList<E>> GetPagedListData(T baseSearch)
        {
            if (IsUseStore) return await base.GetPagedListData(baseSearch);
            PagedList<E> pagedList = new PagedList<E>();

            if (baseSearch.PageSize == 0 && baseSearch.PageIndex == 0)
            {
                baseSearch.PageSize = int.MaxValue;
                baseSearch.PageIndex = 1;
            }

            int skip = (baseSearch.PageIndex - 1) * baseSearch.PageSize;
            int take = baseSearch.PageSize;

            var items = this.Queryable.Where(GetExpression(baseSearch));
            decimal itemCount = items.Count();
            pagedList = new PagedList<E>()
            {
                TotalItem = (int)itemCount,
                Items = await items.OrderBy(baseSearch.OrderBy).Skip(skip).Take(baseSearch.PageSize).ToListAsync(),
                PageIndex = baseSearch.PageIndex,
                PageSize = baseSearch.PageSize,
            };
            return pagedList;
        }

        protected virtual Expression<Func<E, bool>> GetExpression(T baseSearch)
        {
            if (baseSearch.Active != null)
            {
                return e => !e.Deleted && e.Active == baseSearch.Active
                && (string.IsNullOrEmpty(baseSearch.SearchContent)
                    || (e.Code.ToLower().Contains(baseSearch.SearchContent.ToLower())
                    || e.Name.ToLower().Contains(baseSearch.SearchContent.ToLower())
                    || e.Description.ToLower().Contains(baseSearch.SearchContent.ToLower()))
                    );
            }
            else
            {
                return e => !e.Deleted
                && (string.IsNullOrEmpty(baseSearch.SearchContent)
                || (e.Code.ToLower().Contains(baseSearch.SearchContent.ToLower())
                || e.Name.ToLower().Contains(baseSearch.SearchContent.ToLower())
                || e.Description.ToLower().Contains(baseSearch.SearchContent.ToLower()))
                );
            }
        }

        /// <summary>
        /// Import file danh mục
        /// </summary>
        /// <param name="stream"></param>
        /// <param name="createdBy"></param>
        /// <returns></returns>
        public virtual async Task<AppDomainImportResult> ImportTemplateFile(Stream stream, string createdBy)
        {
            AppDomainImportResult appDomainImportResult = new AppDomainImportResult();
            var dataTable = SetDataTable();
            using (var package = new ExcelPackage(stream))
            {
                int totalFailed = 0;
                int totalSuccess = 0;
                var ws = package.Workbook.Worksheets.FirstOrDefault();
                if (ws == null)
                {
                    throw new Exception("Sheet name không tồn tại");
                }
                var existItems = Queryable.Where(e => !e.Deleted);
                var catalogueMappers = new ExcelMapper(stream) { HeaderRow = false, MinRowNumber = 1 }.Fetch<CatalogueMapper>().ToList();
                if (catalogueMappers != null && catalogueMappers.Any())
                {
                    List<string> codeImports = new List<string>();
                    foreach (var catalogueMapper in catalogueMappers)
                    {
                        int index = catalogueMappers.IndexOf(catalogueMapper);
                        int resultIndex = index + 2;
                        IList<string> errors = new List<string>();
                        if (string.IsNullOrEmpty(catalogueMapper.Code))
                            errors.Add("Vui lòng nhập mã");
                        if (existItems.Any(x => x.Code == catalogueMapper.Code) || codeImports.Any(x => x == catalogueMapper.Code))
                            errors.Add("Mã đã tồn tại");
                        if (string.IsNullOrEmpty(catalogueMapper.Name))
                            errors.Add("Vui lòng nhập tên");
                        if (errors.Any())
                        {
                            ws.Cells["D" + resultIndex].Value = string.Join(", ", errors);
                            totalFailed += 1;
                        }
                        else
                        {
                            ws.Cells["D" + resultIndex].Value = "Thành công";
                            totalSuccess += 1;
                            E item = new E()
                            {
                                Code = catalogueMapper.Code,
                                Name = catalogueMapper.Name,
                                Description = catalogueMapper.Description,
                                Deleted = false,
                                Active = true,
                                Created = DateTime.Now,
                                CreatedBy = createdBy,
                            };
                            codeImports.Add(catalogueMapper.Code);
                            dataTable = AddDataTableRow(dataTable, item);
                        }
                    }
                }
                ws.Column(4).Hidden = false;
                ws.Cells.AutoFitColumns();
                appDomainImportResult.Data = new
                {
                    TotalSuccess = totalSuccess,
                    TotalFailed = totalFailed,
                };
                appDomainImportResult.ResultFile = package.GetAsByteArray();
            }
            if (dataTable.Rows.Count > 0)
            {
                var connectionString = string.Format(configuration.GetConnectionString("NhapHangV2DbContext"));
                using (SqlBulkCopy bc = new SqlBulkCopy(connectionString))
                {
                    bc.DestinationTableName = this.GetTableName();
                    bc.BulkCopyTimeout = 4000;
                    await bc.WriteToServerAsync(dataTable);
                }
            }
            appDomainImportResult.Success = true;
            return appDomainImportResult;
        }

        /// <summary>
        /// Lấy thông tin cột đổ vào datatable
        /// </summary>
        /// <returns></returns>
        protected virtual DataTable SetDataTable()
        {
            DataTable table = new DataTable();
            var connectionString = string.Format(configuration.GetConnectionString("NhapHangV2DbContext"));
            using (var adapter = new SqlDataAdapter($"SELECT TOP 0 * FROM " + this.GetTableName(), connectionString))
            {
                adapter.Fill(table);
            };
            return table;
        }

        /// <summary>
        /// Lấy thông tin tên bảng trong DB
        /// </summary>
        /// <returns></returns>
        protected virtual string GetTableName()
        {
            return "";
        }

        /// <summary>
        /// Thêm row mới vào datatable
        /// </summary>
        /// <param name="dt"></param>
        /// <param name="item"></param>
        /// <returns></returns>
        protected virtual DataTable AddDataTableRow(DataTable dt, E item)
        {
            dt.Rows.Add(item.Id, item.Created, item.CreatedBy, item.Updated, item.UpdatedBy, item.Deleted, item.Active, item.Code, item.Name, item.Description);
            return dt;
        }


    }
}
