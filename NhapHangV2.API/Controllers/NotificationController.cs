using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using NhapHangV2.BaseAPI.Controllers;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.Services;
using NhapHangV2.Models;
using NhapHangV2.Request.DomainRequests;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Threading.Tasks;

namespace NhapHangV2.API.Controllers
{
    [Route("api/notification")]
    [ApiController]
    [Description("Thông báo")]
    [Authorize]
    public class NotificationController : BaseController<Notification, NotificationModel, AppDomainRequest, NoticationSearch>
    {
        public NotificationController(IServiceProvider serviceProvider, ILogger<BaseController<Notification, NotificationModel, AppDomainRequest, NoticationSearch>> logger, IWebHostEnvironment env) : base(serviceProvider, logger, env)
        {
            this.domainService = this.serviceProvider.GetRequiredService<INotificationService>();
        }

        /// <summary>
        /// Lấy danh sách item phân trang
        /// Loại thông báo: 0-Yêu cầu nạp,1-Yêu cầu rút, 2-Đơn hàng, 3-Khiếu nại, 4-Tất cả
        /// </summary>
        /// <param name="baseSearch"></param>
        /// <returns></returns>
        [HttpGet]
        [AppAuthorize(new int[] { CoreContants.ViewAll })]
        public override async Task<AppDomainResult> Get([FromQuery] NoticationSearch baseSearch)
        {
            AppDomainResult appDomainResult = new AppDomainResult();

            if (ModelState.IsValid)
            {
                //baseSearch.UID = LoginContext.Instance.CurrentUser.UserId;

                PagedList<Notification> pagedData = await this.domainService.GetPagedListData(baseSearch);
                PagedList<NotificationModel> pagedDataModel = mapper.Map<PagedList<NotificationModel>>(pagedData);

                #region Gán loại cho response
                foreach (var item in pagedDataModel.Items)
                {
                    switch (baseSearch.Type)
                    {
                        case 0:
                            item.Type = 1;
                            break;
                        case 1:
                            item.Type = 1;
                            break;
                        case 2:
                            item.Type = 2;
                            break;
                        case 3:
                            item.Type = 3;
                            break;
                        default:
                            item.Type = 4;
                            break;
                    }                    
                }
                #endregion

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

        /// <summary>
        /// Lấy ra tổng số notification chưa đọc
        /// </summary>
        /// <returns></returns>
        [HttpGet("get-total-notification")]
        public async Task<AppDomainResult> GetTotalNotification(bool ofEmployee)
        {
            int totalNotifications = 0;
            var userNotifications = await this.domainService.GetAsync(e => !e.Deleted
            && !e.IsRead
            && e.ToUserId == LoginContext.Instance.CurrentUser.UserId
            && e.OfEmployee.Equals(ofEmployee)
            );
            if (userNotifications != null && userNotifications.Any())
                totalNotifications = userNotifications.Count();
            return new AppDomainResult()
            {
                Data = totalNotifications,
                Success = true,
                ResultCode = (int)HttpStatusCode.OK
            };
        }

        /// <summary>
        /// Đọc thông báo user
        /// </summary>
        /// <param name="notificationIds"></param>
        /// <returns></returns>
        [HttpPost("read-user-notifications")]
        public async Task<AppDomainResult> ReadNotifications([FromBody] List<int> notificationIds)
        {
            bool success = true;
            var notificationUsers = await this.domainService.GetAsync(e => !e.Deleted
            && e.ToUserId == LoginContext.Instance.CurrentUser.UserId
            && ((notificationIds == null || !notificationIds.Any()) || notificationIds.Contains(e.Id))
            );
            if (notificationUsers != null && notificationUsers.Any())
            {
                foreach (var item in notificationUsers)
                {
                    item.IsRead = true;
                    Expression<Func<Notification, object>>[] includeProperties = new Expression<Func<Notification, object>>[]
                    {
                        e => e.IsRead
                    };
                    success &= await this.domainService.UpdateFieldAsync(item, includeProperties);
                }
            }
            else throw new AppException("Không có thông tin thông báo");
            return new AppDomainResult()
            {
                Success = success,
                ResultCode = (int)HttpStatusCode.OK
            };
        }

        /// <summary>
        /// Ẩn thông báo user
        /// </summary>
        /// <param name="notificationIds"></param>
        /// <returns></returns>
        [HttpPut("hidden-user-notifications")]
        public async Task<AppDomainResult> HiddenNotifications([FromBody] List<int> notificationIds)
        {
            bool success = true;
            var notificationUsers = await this.domainService.GetAsync(e => !e.Deleted
            && e.ToUserId == LoginContext.Instance.CurrentUser.UserId
            && ((notificationIds == null || !notificationIds.Any()) || notificationIds.Contains(e.Id))
            );
            if (notificationUsers != null && notificationUsers.Any())
            {
                foreach (var item in notificationUsers)
                {
                    item.Active = false;
                    item.Deleted = true;
                    Expression<Func<Notification, object>>[] includeProperties = new Expression<Func<Notification, object>>[]
                    {
                        e => e.Active,
                        e => e.Deleted
                    };
                    success &= await this.domainService.UpdateFieldAsync(item, includeProperties);
                }
            }
            else throw new AppException("Không có thông tin thông báo");
            return new AppDomainResult()
            {
                Success = success,
                ResultCode = (int)HttpStatusCode.OK
            };
        }

    }
}
