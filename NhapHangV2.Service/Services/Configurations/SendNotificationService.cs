using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Catalogue;
using NhapHangV2.Entities.Configuration;
using NhapHangV2.Interface.Services;
using NhapHangV2.Interface.Services.Auth;
using NhapHangV2.Interface.Services.Configuration;
using NhapHangV2.Service.Services.Auth;
using NhapHangV2.Utilities;
using NPOI.SS.Formula.Functions;
using OneSignal.RestAPIv3.Client;
using OneSignal.RestAPIv3.Client.Resources.Notifications;
using OneSignal.RestAPIv3.Client.Resources;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.UnitOfWork;
using AutoMapper;
using NhapHangV2.Interface.DbContext;
using System.Threading;

namespace NhapHangV2.Service.Services.Configurations
{
    public class SendNotificationService : ISendNotificationService
    {
        protected readonly IHubContext<DomainHub, IDomainHub> hubContext;
        protected readonly IUserInGroupService userInGroupService;
        protected readonly IUserService userService;
        protected readonly INotificationService notificationService;
        protected readonly IEmailConfigurationService emailConfigurationService;
        protected readonly IConfigurationsService configurationsService;

        public SendNotificationService(IServiceProvider serviceProvider)
        {
            userInGroupService = serviceProvider.GetRequiredService<IUserInGroupService>();
            userService = serviceProvider.GetRequiredService<IUserService>();
            notificationService = serviceProvider.GetRequiredService<INotificationService>();
            hubContext = serviceProvider.GetRequiredService<IHubContext<DomainHub, IDomainHub>>();
            emailConfigurationService = serviceProvider.GetRequiredService<IEmailConfigurationService>();
            configurationsService = serviceProvider.GetRequiredService<IConfigurationsService>();
        }
        public async Task SendNotification(NotificationSetting notificationSetting,
            NotificationTemplate notiTemplate, string contentParam,
            string url, string urlUser, int? userId, string subject, string emailContent)
        {
            if (notificationSetting.IsNotifyAdmin)
            {
                List<Notification> notisAdmin = await createListNotification(1, notiTemplate, "Admin", url, contentParam);
                await SendNotis(notisAdmin, notificationSetting.IsNotifyAdmin, notificationSetting.IsEmailAdmin, subject, emailContent);
                List<Notification> notisManager = await createListNotification(3, notiTemplate, "Quản lý", url, contentParam);
                await SendNotis(notisManager, notificationSetting.IsNotifyAdmin, notificationSetting.IsEmailAdmin, subject, emailContent);
            }

            if (notificationSetting.IsNotifyOrderer)
            {
                List<Notification> notisOderer = await createListNotification(4, notiTemplate, "Đặt hàng", url, contentParam);
                await SendNotis(notisOderer, notificationSetting.IsNotifyOrderer, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifyWarehoueFrom)
            {
                List<Notification> notisTQ = await createListNotification(5, notiTemplate, "Kho TQ", url, contentParam);
                await SendNotis(notisTQ, notificationSetting.IsNotifyWarehoueFrom, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifyWarehoue)
            {
                List<Notification> notisVN = await createListNotification(6, notiTemplate, "Kho VN", url, contentParam);
                await SendNotis(notisVN, notificationSetting.IsNotifyWarehoue, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifySaler)
            {
                List<Notification> notisSaler = await createListNotification(7, notiTemplate, "Seller", url, contentParam);
                await SendNotis(notisSaler, notificationSetting.IsNotifySaler, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifyAccountant)
            {
                List<Notification> notisAccountant = await createListNotification(8, notiTemplate, "Kế toán", url, contentParam);
                await SendNotis(notisAccountant, notificationSetting.IsNotifyAccountant, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifyStorekeepers)
            {
                List<Notification> notisStorekepper = await createListNotification(9, notiTemplate, "Thủ kho", url, contentParam);
                await SendNotis(notisStorekepper, notificationSetting.IsNotifyStorekeepers, false, subject, emailContent);
            }

            if (notificationSetting.IsNotifyUser)
            {
                #region Create cotification to user
                Notification notisUser = new Notification();
                if (userId != null)
                {
                    notisUser = new Notification()
                    {
                        NotificationTemplateId = notiTemplate.Id,
                        Url = urlUser,
                        NotificationContent = string.Format(notiTemplate.Content, contentParam),
                        UserGroupId = (int)PermissionTypes.User,
                        ToUserId = userId.Value,
                        OfEmployee = false
                    };
                }
                #endregion
                await SendNotis(new List<Notification> { notisUser }, notificationSetting.IsNotifyUser, notificationSetting.IsEmailUser, subject, emailContent);
            }
        }

        private async Task<List<Notification>> createListNotification(int roleId, NotificationTemplate notiTemplate, string prefix, string url, string contentParam)
        {
            List<Notification> notis = new List<Notification>();
            var useInGroupAdmins = await userInGroupService.GetUserInGroupsByUserGroupId(roleId);

            foreach (var admin in useInGroupAdmins)
            {
                notis.Add(new Notification()
                {
                    NotificationTemplateId = notiTemplate.Id,
                    Url = url,
                    NotificationContent = string.Format($"{prefix} - " + notiTemplate.Content, contentParam),
                    ToUserId = admin.UserId,
                    OfEmployee = true
                }); ;
            }
            return notis;
        }
        private async Task SendNotis(List<Notification> notis, bool isNoti, bool isEmail, string subject, string emailContent)
        {
            var confi = await configurationsService.GetSingleAsync();
            if (isNoti)
            {
                var playerIds = new List<string>();
                Guid appId = Guid.Parse(confi.OneSignalAppID);
                string restAPIKey = confi.RestAPIKey;
                foreach (var noti in notis)
                {
                    await notificationService.CreateAsync(noti);
                    await hubContext.Clients.Groups(new List<string>
                    {
                        string.Format("UserId_{0}", noti.ToUserId)
                    }).SendNotification(noti);
                    var user = await userService.GetByIdAsync(noti.ToUserId);
                    if (user != null)
                    {
                        playerIds.Add(user.OneSignalPlayerID);
                        if (user.OneSignalPlayerID != null)
                        {
                            Thread t = new Thread(()=>
                            {
                                OneSignalPushNotification(playerIds, $"{confi.WebsiteName}", noti, appId, restAPIKey);
                            });
                            t.Start();
                        }
                    }
                }

            }
            if (isEmail)
            {
                foreach (var noti in notis)
                {
                    var user = await userService.GetByIdAsync(noti.ToUserId);
                    if (user != null)
                    {
                        await emailConfigurationService.Send(subject, new string[] { user.Email }, null, null, new EmailContent()
                        {
                            IsHtml = true,
                            Content = emailContent
                        });
                    }
                }
            }
        }

        private async Task OneSignalPushNotification(List<string> playerIds, string heading, Notification notification, Guid appId, string restKey)
        {
            var confi = await configurationsService.GetSingleAsync();

            OneSignalClient client = new OneSignalClient(restKey);
            var opt = new NotificationCreateOptions()
            {
                AppId = appId,
                IncludePlayerIds = playerIds,
                SendAfter = DateTime.Now.AddSeconds(5)
            };
            opt.Headings.Add(LanguageCodes.English, heading);
            opt.Contents.Add(LanguageCodes.English, notification.NotificationContent);
            opt.Url = $"{confi.WebsiteUrl}/{notification.Url}";
            try
            {
                await client.Notifications.CreateAsync(opt);
            }
            catch (AppException)
            {
                throw new AppException("Gửi thông báo One Signal thất bại");
            }
        }
    }
}
