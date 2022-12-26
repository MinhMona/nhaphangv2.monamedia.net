using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using NhapHangV2.BaseAPI.Controllers;
using NhapHangV2.Entities;
using NhapHangV2.Entities.DomainEntities;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.Services;
using NhapHangV2.Models;
using NhapHangV2.Request;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace NhapHangV2.API.Controllers
{
    [Route("api/order-temp")]
    [Description("Quản lý sản phẩm trong giỏ hàng")]
    [ApiController]
    [Authorize]
    public class OrderTempController : BaseController<OrderTemp, OrderTempModel, OrderTempRequest, OrderTempSearch>
    {
        private readonly IOrderShopTempService orderShopTempService;
        public OrderTempController(IServiceProvider serviceProvider, ILogger<BaseController<OrderTemp, OrderTempModel, OrderTempRequest, OrderTempSearch>> logger, IWebHostEnvironment env) : base(serviceProvider, logger, env)
        {
            this.domainService = this.serviceProvider.GetRequiredService<IOrderTempService>();
            orderShopTempService = serviceProvider.GetRequiredService<IOrderShopTempService>();
        }

        [HttpDelete("{id}")]
        [AppAuthorize(new int[] { CoreContants.Delete })]
        public override async Task<AppDomainResult> DeleteItem(int id)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            var item = await this.domainService.GetByIdAsync(id);
            bool success = await this.domainService.DeleteAsync(id);
            if (success)
            {
                appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                appDomainResult.Success = success;
                appDomainResult.Data = mapper.Map<OrderShopTempModel>(await orderShopTempService.GetByIdAsync(item.OrderShopTempId ?? 0));
            }
            else
                throw new Exception("Lỗi trong quá trình xử lý");

            return appDomainResult;
        }

        /// <summary>
        /// Cập nhật thông tin item
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPut]
        [AppAuthorize(new int[] { CoreContants.Update })]
        public override async Task<AppDomainResult> UpdateItem([FromBody] OrderTempRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            if (ModelState.IsValid)
            {
                var item = mapper.Map<OrderTemp>(itemModel);
                if (item != null)
                {
                    // Kiểm tra item có tồn tại chưa?
                    var messageUserCheck = await this.domainService.GetExistItemMessage(item);
                    if (!string.IsNullOrEmpty(messageUserCheck))
                        throw new AppException(messageUserCheck);
                    success = await this.domainService.UpdateAsync(item);
                    if (success)
                    {
                        appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                        appDomainResult.Data = this.domainService.GetByIdAsync(item.Id);
                    }
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
        /// Update số lượng và ghi chú
        /// </summary>
        /// <param name="itemModel"></param>
        /// <returns></returns>
        [HttpPut("update-brand-and-quantity")]
        [AppAuthorize(new int[] { CoreContants.Update })]
        public async Task<AppDomainResult> UpdateBrandAndQuantity([FromBody] UpdateBrandAndQuantityOrderTempRequest itemModel)
        {
            AppDomainResult appDomainResult = new AppDomainResult();
            bool success = false;
            if (ModelState.IsValid)
            {
                // Kiểm tra item có tồn tại chưa?
                var item = await this.domainService.GetByIdAsync(itemModel.Id ?? 0);
                if (item == null)
                    throw new KeyNotFoundException("Id không tồn tại");

                if (item != null)
                {
                    item.Quantity = itemModel.Quantity;
                    item.Brand = !string.IsNullOrEmpty(itemModel.Brand) ? itemModel.Brand.ToString() : string.Empty;

                    success = await this.domainService.UpdateAsync(item);
                    if (success)
                    {
                        appDomainResult.ResultCode = (int)HttpStatusCode.OK;
                        appDomainResult.Data = mapper.Map<OrderShopTempModel>(await orderShopTempService.GetByIdAsync(item.OrderShopTempId ?? 0));
                    }
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
    }
}
