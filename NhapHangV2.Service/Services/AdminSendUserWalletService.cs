using AutoMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Catalogue;
using NhapHangV2.Entities.Configuration;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.DbContext;
using NhapHangV2.Interface.Services;
using NhapHangV2.Interface.Services.Auth;
using NhapHangV2.Interface.Services.Catalogue;
using NhapHangV2.Interface.Services.Configuration;
using NhapHangV2.Interface.UnitOfWork;
using NhapHangV2.Service.Services.Auth;
using NhapHangV2.Service.Services.Catalogue;
using NhapHangV2.Service.Services.DomainServices;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.Service.Services
{
    public class AdminSendUserWalletService : DomainService<AdminSendUserWallet, AdminSendUserWalletSearch>, IAdminSendUserWalletService
    {
        protected readonly IUserService userService;
        protected readonly IUserInGroupService userInGroupService;
        private readonly INotificationSettingService notificationSettingService;
        private readonly INotificationTemplateService notificationTemplateService;
        private readonly ISendNotificationService sendNotificationService;
        private readonly ISMSEmailTemplateService sMSEmailTemplateService;

        public AdminSendUserWalletService(IServiceProvider serviceProvider, IAppUnitOfWork unitOfWork, IMapper mapper) : base(unitOfWork, mapper)
        {
            userInGroupService = serviceProvider.GetRequiredService<IUserInGroupService>();
            notificationSettingService = serviceProvider.GetRequiredService<INotificationSettingService>();
            notificationTemplateService = serviceProvider.GetRequiredService<INotificationTemplateService>();
            sendNotificationService = serviceProvider.GetRequiredService<ISendNotificationService>();
            userService = serviceProvider.GetRequiredService<IUserService>();
            sMSEmailTemplateService = serviceProvider.GetRequiredService<ISMSEmailTemplateService>();

        }

        public override async Task<AdminSendUserWallet> GetByIdAsync(int id)
        {
            var adminSendUserWallet = await Queryable.Where(e => e.Id == id && !e.Deleted).AsNoTracking().FirstOrDefaultAsync();
            if (adminSendUserWallet == null)
                return null;
            var user = await unitOfWork.Repository<Users>().GetQueryable().Where(e => !e.Deleted && e.Id == adminSendUserWallet.UID).FirstOrDefaultAsync();
            if (user != null)
                adminSendUserWallet.UserName = user.UserName;
            return adminSendUserWallet;
        }

        protected override string GetStoreProcName()
        {
            return "AdminSendUserWallet_GetPagingData";
        }

        public async Task<bool> UpdateStatus(AdminSendUserWallet item, int status)
        {
            var currentUser = LoginContext.Instance.CurrentUser;
            var user = new Users();
            if (item.UID == 0 || item.UID == null)
            {
                user = await userService.GetByIdAsync(LoginContext.Instance.CurrentUser.UserId); //User
                if (user.IsAdmin || (user.UserGroupId != (int)PermissionTypes.Accountant || user.UserGroupId != (int)PermissionTypes.Manager))
                { }
                else throw new InvalidCastException(string.Format("Bạn không có quyền duyệt yêu cầu này"));
            }
            else
                user = await userService.GetByIdAsync(item.UID ?? 0); //Admin nạp / rút dùm

            if (user == null) throw new KeyNotFoundException("Không tìm thấy User");

            item.UID = user.Id;

            switch (status)
            {
                case (int)WalletStatus.DaDuyet: //Duyệt

                    //Cập nhật ví tiền
                    user.Wallet += item.Amount;
                    await userService.UpdateAsync(user);

                    //Lịch sử ví tiền VNĐ
                    await unitOfWork.Repository<HistoryPayWallet>().CreateAsync(new HistoryPayWallet
                    {
                        UID = user.Id,
                        MainOrderId = 0,
                        MoneyLeft = user.Wallet,
                        Amount = item.Amount,
                        Type = (int)DauCongVaTru.Cong,
                        TradeType = (int)HistoryPayWalletContents.AdminChuyenTien,
                        Content = string.IsNullOrEmpty(item.TradeContent) ? string.Format("{0} đã được nạp tiền vào tài khoản.", user.UserName) : item.TradeContent,
                    });

                    item.Status = (int)WalletStatus.DaDuyet;

                    //Thông báo nạp VND
                    var notificationSetting = await notificationSettingService.GetByIdAsync(3);
                    notificationSetting.IsNotifyAdmin = notificationSetting.IsEmailAdmin = false;
                    var notiTemplate = await notificationTemplateService.GetByIdAsync(23);

                    await sendNotificationService.SendNotification(notificationSetting, notiTemplate, string.Format("{0:N0}", item.Amount.ToString()), string.Empty, "/user/history-transaction-vnd", user.Id, string.Empty, string.Empty);

                    break;
                case (int)WalletStatus.Huy: //Hủy
                    item.Status = (int)WalletStatus.Huy;
                    //Thông báo hủy VND
                    var notificationSettingHuy = await notificationSettingService.GetByIdAsync(3);
                    var notiTemplateHuy = await notificationTemplateService.GetByIdAsync(27);
                    if (currentUser.UserGroupId == 2)
                    {
                        await sendNotificationService.SendNotification(notificationSettingHuy, notiTemplateHuy, item.Id.ToString(), "/manager/money/recharge-history", string.Empty, null, string.Empty, string.Empty);
                    }
                    else
                    {
                        notificationSettingHuy.IsNotifyAdmin = notificationSettingHuy.IsEmailAdmin = false;
                        notiTemplateHuy.Content = $"Yêu cầu nạp {item.Id} của bạn đã bị {currentUser.UserName} hủy";
                        await sendNotificationService.SendNotification(notificationSettingHuy, notiTemplateHuy, string.Empty, string.Empty, "/user/recharge-vnd", item.UID, string.Empty, string.Empty);

                    }
                    break;
                default:
                    break;
            }

            unitOfWork.Repository<AdminSendUserWallet>().Update(item);
            await unitOfWork.SaveAsync();
            return true;
        }

        public override async Task<bool> CreateAsync(AdminSendUserWallet item)
        {
            var user = await userService.GetByIdAsync(item.UID ?? 0);
            var emailTemplate = new SMSEmailTemplates();
            var currentUser = LoginContext.Instance.CurrentUser;
            if (item.UID == currentUser.UserId)
            {
                emailTemplate = await sMSEmailTemplateService.GetByCodeAsync("AYCNTM");
                item.CreatedBy = user.UserName;
            }
            else
            {
                emailTemplate = await sMSEmailTemplateService.GetByCodeAsync("UDNVTK");
                item.CreatedBy = item.UpdatedBy = currentUser.UserName;
                item.Updated = DateTime.Now;
            }
            if (user == null) throw new KeyNotFoundException("Không tìm thấy User");

            item.UID = user.Id;
            item.Created = DateTime.Now;
            if (item.Status == (int)WalletStatus.DaDuyet)
            {
                user.Wallet += item.Amount ?? 0;
                unitOfWork.Repository<Users>().Update(user);

                await unitOfWork.Repository<HistoryPayWallet>().CreateAsync(new HistoryPayWallet
                {
                    UID = user.Id,
                    Amount = item.Amount,
                    Content = item.TradeContent,
                    MoneyLeft = user.Wallet,
                    Type = (int)DauCongVaTru.Cong,
                    TradeType = (int)HistoryPayWalletContents.AdminChuyenTien
                });
            }

            await unitOfWork.Repository<AdminSendUserWallet>().CreateAsync(item);

            await unitOfWork.SaveAsync();
            //Thông báo
            //Thông báo tới admin và manager có yêu cầu nạp tiền VND
            var notificationSetting = await notificationSettingService.GetByIdAsync(3);
            notificationSetting.IsNotifyUser = notificationSetting.IsEmailUser = false;
            var notiTemplate = await notificationTemplateService.GetByIdAsync(8);
            string subject = emailTemplate.Subject;
            string emailContent = string.Format(emailTemplate.Body);
            await sendNotificationService.SendNotification(notificationSetting, notiTemplate, string.Empty, "/manager/money/recharge-history", "", item.UID, subject, emailContent);
            return true;
        }

        public override async Task<bool> UpdateAsync(AdminSendUserWallet item)
        {
            return await UpdateStatus(item, item.Status ?? 0);
        }

        public async Task<BillInfor> GetBillInforAsync(int id)
        {
            var item = await Queryable.Where(e => e.Id == id && !e.Deleted).AsNoTracking().FirstOrDefaultAsync();
            if (item != null)
            {
                var user = await userService.GetByIdAsync(item.UID ?? 0);
                var billInfor = new BillInfor()
                {
                    UserName = user.FullName,
                    UserAddress = user.Address,
                    Note = item.TradeContent,
                    Amount = item.Amount ?? 0
                };
                return billInfor;
            }
            throw new EntryPointNotFoundException("Không tìm thấy yêu cầu");
        }
    }
}
