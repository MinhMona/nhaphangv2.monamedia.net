using AutoMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using NhapHangV2.API.Controllers.Catalogue;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Catalogue;
using NhapHangV2.Entities.DomainEntities;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.Services;
using NhapHangV2.Interface.Services.Catalogue;
using NhapHangV2.Models;
using NhapHangV2.Models.Catalogue;
using NhapHangV2.Request;
using NhapHangV2.Request.Catalogue;
using NhapHangV2.Service.Services.Catalogue;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Net;
using System.Threading.Tasks;

namespace NhapHangV2.API.Controllers
{
    [Route("api/contact-us")]
    [ApiController]
    [Description("Liên hệ với chúng tôi")]
    public class ContactUsController : ControllerBase
    {
        protected IMapper mapper;
        protected readonly IContactUsService contactUsService;
        public ContactUsController(IServiceProvider serviceProvider, IMapper mapper)
        {
            contactUsService = serviceProvider.GetRequiredService<IContactUsService>();
            this.mapper = mapper;
        }
        /// <summary>
        /// Thêm mới item
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<AppDomainResult> AddItem([FromBody] ContactUsRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            if (ModelState.IsValid)
            {
                var item = mapper.Map<ContactUs>(itemModel);
                success = await contactUsService.CreateAsync(item);
                if (success)
                {
                    appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                    appDomainResult.Data = item;
                }
                appDomainResult.Success = success;
            }
            else
                throw new AppException(ModelState.GetErrorMessage());
            return appDomainResult;
        }
        /// <summary>
        /// Lấy danh sách item phân trang
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        [HttpGet]
        [AppAuthorize(new int[] { CoreContants.ViewAll })]
        public async Task<AppDomainResult> Get([FromQuery] ContactUsSearch baseSearch)
        {
            AppDomainResult appDomainResult = new AppDomainResult();

            if (ModelState.IsValid)
            {
                PagedList<ContactUs> pagedData = await contactUsService.GetPagedListData(baseSearch);
                PagedList<ContactUsModel> pagedDataModel = mapper.Map<PagedList<ContactUsModel>>(pagedData);
                appDomainResult = new AppDomainResult
                {
                    Data = pagedDataModel,
                    Success = true,
                    ResultCode = (int)HttpStatusCode.OK
                };
            }
            else
                throw new AppException(ModelState.GetErrorMessage());
            return appDomainResult;
        }
    }
}
