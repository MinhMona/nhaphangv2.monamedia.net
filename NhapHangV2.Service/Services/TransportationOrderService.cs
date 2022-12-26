using AutoMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using NhapHangV2.Entities;
using NhapHangV2.Entities.Catalogue;
using NhapHangV2.Entities.Search;
using NhapHangV2.Extensions;
using NhapHangV2.Interface.DbContext;
using NhapHangV2.Interface.Services;
using NhapHangV2.Interface.Services.Auth;
using NhapHangV2.Interface.Services.Catalogue;
using NhapHangV2.Interface.Services.Configuration;
using NhapHangV2.Interface.UnitOfWork;
using NhapHangV2.Request;
using NhapHangV2.Service.Services.Auth;
using NhapHangV2.Service.Services.Catalogue;
using NhapHangV2.Service.Services.DomainServices;
using NhapHangV2.Utilities;
using NPOI.POIFS.Crypt.Dsig;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.Service.Services
{
    public class TransportationOrderService : DomainService<TransportationOrder, TransportationOrderSearch>, ITransportationOrderService
    {
        protected readonly IAppDbContext Context;
        protected readonly IUserService userService;
        protected readonly IConfigurationsService configurationsService;
        protected readonly IWarehouseFeeService warehouseFeeService;
        protected readonly IRequestOutStockService requestOutStockService;
        protected readonly IHistoryPayWalletService historyPayWalletService;
        private readonly INotificationSettingService notificationSettingService;
        private readonly INotificationTemplateService notificationTemplateService;
        private readonly ISendNotificationService sendNotificationService;
        protected readonly IUserInGroupService userInGroupService;
        private readonly ISMSEmailTemplateService sMSEmailTemplateService;
        private readonly IServiceProvider serviceProvider;

        public TransportationOrderService(IServiceProvider serviceProvider, IAppUnitOfWork unitOfWork, IMapper mapper, IAppDbContext Context) : base(unitOfWork, mapper)
        {
            this.Context = Context;
            this.serviceProvider = serviceProvider;
            userService = serviceProvider.GetRequiredService<IUserService>();
            configurationsService = serviceProvider.GetRequiredService<IConfigurationsService>();
            warehouseFeeService = serviceProvider.GetRequiredService<IWarehouseFeeService>();
            requestOutStockService = serviceProvider.GetRequiredService<IRequestOutStockService>();
            historyPayWalletService = serviceProvider.GetRequiredService<IHistoryPayWalletService>();
            notificationSettingService = serviceProvider.GetRequiredService<INotificationSettingService>();
            notificationTemplateService = serviceProvider.GetRequiredService<INotificationTemplateService>();
            sendNotificationService = serviceProvider.GetRequiredService<ISendNotificationService>();
            userInGroupService = serviceProvider.GetRequiredService<IUserInGroupService>();
            sMSEmailTemplateService = serviceProvider.GetRequiredService<ISMSEmailTemplateService>();

        }

        protected override string GetStoreProcName()
        {
            return "TransportationOrder_GetPagingData";
        }

        public override async Task<PagedList<TransportationOrder>> GetPagedListData(TransportationOrderSearch baseSearch)
        {
            PagedList<TransportationOrder> pagedList = new PagedList<TransportationOrder>();
            SqlParameter[] parameters = GetSqlParameters(baseSearch);
            pagedList = await this.unitOfWork.Repository<TransportationOrder>().ExcuteQueryPagingAsync(this.GetStoreProcName(), parameters);
            //Lấy cân tính tiền
            foreach (var item in pagedList.Items)
            {
                var smallPackage = await this.unitOfWork.Repository<SmallPackage>().GetQueryable().Where(e => !e.Deleted && e.Id == item.SmallPackageId).FirstOrDefaultAsync();
                if (smallPackage != null)
                    item.PayableWeight = smallPackage.PayableWeight;
            }
            pagedList.PageIndex = baseSearch.PageIndex;
            pagedList.PageSize = baseSearch.PageSize;
            return pagedList;
        }

        public override async Task<TransportationOrder> GetByIdAsync(int id)
        {
            var transportationOrder = await Queryable.Where(e => e.Id == id && !e.Deleted).AsNoTracking().FirstOrDefaultAsync();
            if (transportationOrder == null)
                return null;
            var smallPackages = await unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => !x.Deleted && x.TransportationOrderId == transportationOrder.Id).OrderByDescending(o => o.Id).ToListAsync();
            if (smallPackages.Any())
                transportationOrder.SmallPackages = smallPackages;

            //Lấy cân tính tiền
            var smallPackage = smallPackages.Where(e => e.TransportationOrderId == transportationOrder.Id).FirstOrDefault();
            transportationOrder.PayableWeight = (smallPackage != null && smallPackage.PayableWeight != null) ? smallPackage.PayableWeight : 0;

            var user = await unitOfWork.Repository<Users>().GetQueryable().Where(e => !e.Deleted && e.Id == transportationOrder.UID).FirstOrDefaultAsync();
            if (user != null)
                transportationOrder.UserName = user.UserName;

            var warehouseFrom = await unitOfWork.CatalogueRepository<WarehouseFrom>().GetQueryable().Where(e => !e.Deleted && e.Id == transportationOrder.WareHouseFromId).FirstOrDefaultAsync();
            if (warehouseFrom != null)
                transportationOrder.WareHouseFrom = warehouseFrom.Name;

            var warehouseTo = await unitOfWork.CatalogueRepository<Warehouse>().GetQueryable().Where(e => !e.Deleted && e.Id == transportationOrder.WareHouseId).FirstOrDefaultAsync();
            if (warehouseTo != null)
                transportationOrder.WareHouseTo = warehouseTo.Name;

            var shippingType = await unitOfWork.CatalogueRepository<ShippingTypeToWareHouse>().GetQueryable().Where(e => !e.Deleted && e.Id == transportationOrder.ShippingTypeId).FirstOrDefaultAsync();
            if (shippingType != null)
                transportationOrder.ShippingTypeName = shippingType.Name;

            var shippingTypeVN = await unitOfWork.CatalogueRepository<ShippingTypeVN>().GetQueryable().Where(e => !e.Deleted && e.Id == transportationOrder.ShippingTypeVN).FirstOrDefaultAsync();
            if (shippingTypeVN != null)
                transportationOrder.ShippingTypeVNName = shippingTypeVN.Name;

            return transportationOrder;
        }

        public override async Task<bool> UpdateAsync(TransportationOrder item)
        {
            if (item.Status == (int)StatusGeneralTransportationOrder.DaDuyet)
            {
                using (var dbContextTransaction = Context.Database.BeginTransaction())
                {
                    try
                    {
                        var smallPackage = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.OrderTransactionCode.Equals(item.OrderTransactionCode)).FirstOrDefault();
                        if (smallPackage == null)
                        {
                            smallPackage = new SmallPackage();
                            smallPackage.UID = item.UID;
                            smallPackage.TransportationOrderId = item.Id;
                            smallPackage.OrderTransactionCode = item.OrderTransactionCode;
                            smallPackage.ProductType = item.Category;
                            smallPackage.BigPackageId = 0;
                            smallPackage.FeeShip = smallPackage.Weight = 0;
                            smallPackage.Status = (int)StatusSmallPackage.MoiDat;

                            smallPackage.Deleted = false;
                            smallPackage.Active = true;
                            smallPackage.Created = item.Created;
                            smallPackage.CreatedBy = item.CreatedBy;

                            smallPackage.IsInsurance = item.IsInsurance;
                            smallPackage.IsCheckProduct = item.IsCheckProduct;
                            smallPackage.IsPackged = item.IsPacked;
                            smallPackage.TotalOrderQuantity = (int)item.Amount;
                            await unitOfWork.Repository<SmallPackage>().CreateAsync(smallPackage);
                            await unitOfWork.SaveAsync();

                            item.SmallPackageId = smallPackage.Id;

                            unitOfWork.Repository<TransportationOrder>().Update(item);
                        }
                        else
                        {
                            if (item.SmallPackages.Count > 0)
                            {
                                unitOfWork.Repository<TransportationOrder>().Update(item);
                            }
                            else
                            {
                                throw new AppException("Mã vận đơn đã tồn tại ở đơn ký gửi khác");
                            }
                        }
                        await unitOfWork.SaveAsync();
                        await dbContextTransaction.CommitAsync();
                    }
                    catch (Exception ex)
                    {
                        await dbContextTransaction.RollbackAsync();
                        throw new Exception(ex.Message);
                    }
                }
            }
            else
            {
                unitOfWork.Repository<TransportationOrder>().Update(item);
                foreach (var smallPackage in item.SmallPackages)
                {
                    smallPackage.DonGia = item.FeeWeightPerKg;
                    smallPackage.OrderTransactionCode = smallPackage.OrderTransactionCode.Replace(" ", "");
                    unitOfWork.Repository<SmallPackage>().Update(smallPackage);
                }
                await unitOfWork.SaveAsync();
            }
            return true;

        }

        public override async Task<bool> CreateAsync(IList<TransportationOrder> items)
        {
            using (var dbContextTransaction = Context.Database.BeginTransaction())
            {
                try
                {
                    foreach (var item in items)
                    {
                        await unitOfWork.Repository<TransportationOrder>().CreateAsync(item);
                        await unitOfWork.SaveAsync();

                        //Thông báo có đơn đặt hàng mới
                        var notiTemplate = await notificationTemplateService.GetByIdAsync(9);
                        var notificationSetting = await notificationSettingService.GetByIdAsync(5);
                        var emailTemplate = await sMSEmailTemplateService.GetByCodeAsync("ADHM");
                        string subject = emailTemplate.Subject;
                        string emailContent = string.Format(emailTemplate.Body); //Thông báo Email
                        await sendNotificationService.SendNotification(notificationSetting, notiTemplate, item.Id.ToString(), $"/manager/deposit/deposit-list/{item.Id}", "", item.Id, subject, emailContent);

                        //var smallPackage = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.TransportationOrderId == item.Id).FirstOrDefault();
                        //if (smallPackage == null)
                        //{
                        //    smallPackage = new SmallPackage();
                        //    smallPackage.UID = item.UID;
                        //    smallPackage.TransportationOrderId = item.Id;
                        //    smallPackage.OrderTransactionCode = item.OrderTransactionCode;
                        //    smallPackage.ProductType = item.Category;
                        //    smallPackage.BigPackageId = 0;
                        //    smallPackage.FeeShip = smallPackage.Weight = 0;
                        //    smallPackage.Status = (int)StatusGeneralTransportationOrder.ChoDuyet;

                        //    smallPackage.Deleted = false;
                        //    smallPackage.Active = true;
                        //    smallPackage.Created = item.Created;
                        //    smallPackage.CreatedBy = item.CreatedBy;

                        //    smallPackage.IsInsurance = item.IsInsurance;
                        //    smallPackage.IsCheckProduct = item.IsCheckProduct;
                        //    smallPackage.IsPackged = item.IsPacked;
                        //    smallPackage.TotalOrderQuantity = (int)item.Amount;
                        //    await unitOfWork.Repository<SmallPackage>().CreateAsync(smallPackage);
                        //    await unitOfWork.SaveAsync();

                        //    item.SmallPackageId = smallPackage.Id;

                        //    unitOfWork.Repository<TransportationOrder>().Update(item);
                        //}
                    }
                    await unitOfWork.SaveAsync();
                    await dbContextTransaction.CommitAsync();
                }
                catch (Exception ex)
                {
                    await dbContextTransaction.RollbackAsync();
                    throw new Exception(ex.Message);
                }
            }
            return true;
        }

        public async Task<TransportationOrderBilling> GetBillingInfo(List<int> listID, bool isUpdated)
        {
            TransportationOrderBilling model = new TransportationOrderBilling();
            DateTime currentDate = DateTime.Now;
            string userName = LoginContext.Instance.CurrentUser.UserName;
            var users = await userService.GetSingleAsync(x => x.UserName == userName);
            decimal wallet = users.Wallet ?? 0;

            decimal current = 0;
            decimal feeOutStockCNY = 0;
            decimal feeOutStockVND = 0;
            var config = await configurationsService.GetSingleAsync();
            if (config != null)
            {
                current = config.AgentCurrency ?? 0;
                feeOutStockCNY = config.PriceCheckOutWareDefault ?? 0;
                feeOutStockVND = current * feeOutStockCNY;
            }

            var listTrans = await base.GetAsync(x => !x.Deleted && x.Active
                && listID.Contains(x.Id)
            );
            if (!listTrans.Any())
                throw new KeyNotFoundException(string.Format("Không tồn tại dữ liệu. Vui lòng kiểm tra lại"));

            var checkStatus = listTrans.Where(x => x.Status == (int?)StatusGeneralTransportationOrder.VeKhoVN).Count();
            if (listTrans.Count() != checkStatus) //Nếu số lượng khác nhau
                throw new AppException(string.Format("Có đơn bị sai trạng thái thanh toán, vui lòng kiểm tra lại"));

            decimal totalAdditionFeeCNY = 0;
            decimal totalAdditionFeeVND = 0;

            decimal totalSensoredFeeVND = 0;
            decimal totalSensoredFeeCNY = 0;

            var checkWarehouseList = new List<CheckWarehouse>();
            var checkWarehouse = new CheckWarehouse();
            foreach (var item in listTrans)
            {
                checkWarehouse = checkWarehouseList.Where(x => x.WareHouseId == item.WareHouseId
                    && x.WareHouseFromId == item.WareHouseFromId
                    && x.ShippingTypeId == item.ShippingTypeId).FirstOrDefault();
                if (checkWarehouse != null)
                {
                    if (item.SmallPackageId == null && item.SmallPackageId <= 0)
                        continue;

                    var package = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.Id == item.SmallPackageId).FirstOrDefault();
                    if (package == null && (package.Weight == null && package.Weight <= 0))
                        continue;

                    decimal weight = package.Weight ?? 0;

                    checkWarehouse.TotalWeight += weight;
                    checkWarehouse.Packages.Add(new Package
                    {
                        Weight = weight,
                        TransportationId = item.Id
                    });
                }
                else
                {
                    checkWarehouse = new CheckWarehouse();
                    checkWarehouse.WareHouseFromId = item.WareHouseFromId ?? 0;
                    checkWarehouse.WareHouseId = item.WareHouseId ?? 0;
                    checkWarehouse.ShippingTypeId = item.ShippingTypeId ?? 0;

                    if (item.SmallPackageId == null && item.SmallPackageId <= 0)
                        continue;

                    var package = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.Id == item.SmallPackageId).FirstOrDefault();
                    if (package == null && (package.Weight == null && package.Weight <= 0))
                        continue;

                    decimal weight = package.Weight ?? 0;

                    checkWarehouse.TotalWeight += weight;
                    checkWarehouse.Packages.Add(new Package
                    {
                        Weight = weight,
                        TransportationId = item.Id
                    });

                    totalAdditionFeeCNY += package.AdditionFeeCNY ?? 0;
                    totalAdditionFeeVND += package.AdditionFeeVND ?? 0;

                    totalSensoredFeeVND += package.SensorFeeVND ?? 0;
                    totalSensoredFeeCNY += package.SensorFeeCNY ?? 0;

                    checkWarehouseList.Add(checkWarehouse);
                }
            }

            decimal totalWeightPriceVND = 0;
            decimal totalWeightPriceCNY = 0;
            if (!string.IsNullOrEmpty(users.FeeTQVNPerWeight.ToString()) && users.FeeTQVNPerWeight > 0)
            {
                totalWeightPriceVND = users.FeeTQVNPerWeight ?? 0 * checkWarehouse.TotalWeight;
                if (isUpdated) //Nếu bằng true thì add vào để xuống thanh toán insert
                {
                    foreach (var item in listTrans)
                    {
                        var package = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.Id == item.SmallPackageId).FirstOrDefault();
                        if (package == null && (package.Weight == null && package.Weight <= 0))
                            continue;

                        model.ModelUpdatePayments.Add(new ModelUpdatePayment
                        {
                            Id = item.Id,
                            Price = package.PayableWeight * users.FeeTQVNPerWeight,
                            Weight = users.FeeTQVNPerWeight
                        });
                    }
                }
            }
            else
            {
                foreach (var item in checkWarehouseList)
                {
                    var fee = await warehouseFeeService.GetAsync(c => !c.Deleted && c.Active
                        && (c.WarehouseFromId == item.WareHouseFromId
                            && c.WarehouseId == item.WareHouseId
                            && c.ShippingTypeToWareHouseId == item.ShippingTypeId
                            && c.IsHelpMoving == true)
                    );

                    if (!fee.Any())
                        continue;

                    var f = fee.Where(f => item.TotalWeight >= f.WeightFrom && item.TotalWeight <= f.WeightTo).FirstOrDefault();
                    if (f == null)
                        continue;

                    totalWeightPriceVND += f.Price * item.TotalWeight ?? 0;

                    if (isUpdated && item.Packages != null) //Nếu có điều kiện này thì đưa data xuống lát update nè
                    {
                        foreach (var jtem in item.Packages)
                        {
                            model.ModelUpdatePayments.Add(new ModelUpdatePayment
                            {
                                Id = jtem.TransportationId,
                                Price = jtem.Weight * f.Price,
                                Weight = f.Price
                            });
                        }
                    }
                }
            }

            decimal totalPriceVND = totalWeightPriceVND + feeOutStockVND + totalSensoredFeeVND + totalAdditionFeeVND;
            decimal totalPriceCNY = totalWeightPriceCNY + feeOutStockCNY + totalSensoredFeeCNY + totalSensoredFeeCNY;

            if (wallet >= totalPriceVND)
                model.LeftMoney = 0; //Đủ tiền
            else
                model.LeftMoney = totalPriceVND - wallet; //Không đủ tiền

            model.TotalQuantity = listTrans.Count;
            model.TotalWeight = checkWarehouseList.Sum(x => x.TotalWeight);

            model.TotalWeightPriceCNY = totalWeightPriceCNY;
            model.TotalWeightPriceVND = totalWeightPriceVND;

            model.FeeOutStockCNY = feeOutStockCNY;
            model.FeeOutStockVND = feeOutStockVND;

            model.TotalPriceCNY = totalPriceCNY;
            model.TotalPriceVND = totalPriceVND;

            model.ListId = listID;

            model.TotalAdditionFeeCNY = totalAdditionFeeCNY;
            model.TotalAdditionFeeVND = totalAdditionFeeVND;

            model.TotalSensoredFeeCNY = totalSensoredFeeCNY;
            model.TotalSensoredFeeVND = totalSensoredFeeVND;

            return model;
        }

        public async Task<bool> UpdateAsync(IList<TransportationOrder> item, int status, int typePayment)
        {
            DateTime currentDate = DateTime.Now;
            string userName = LoginContext.Instance.CurrentUser.UserName;
            var users = await userService.GetSingleAsync(x => x.UserName == userName);
            switch (status)
            {
                case (int)StatusGeneralTransportationOrder.Huy: //Hủy thì ngoài controller đã làm hết rồi, vào đây chỉ cập nhật thôi
                    foreach (var tran in item)
                    {

                    }
                    await base.UpdateAsync(item);
                    break;
                case (int)StatusGeneralTransportationOrder.DaThanhToan: //Thanh toán thì ngoài controller đã làm hết rồi, vào đây chỉ cập nhật thôi

                    //Giống với Xuất kho chưa yêu cầu(ExportRequestTurn/Create)
                    var info = await GetBillingInfo(item.Select(x => x.Id).ToList(), true); //Lấy data tính từ trước
                    if (!info.ModelUpdatePayments.Any())
                        throw new KeyNotFoundException("Không tìm thấy dữ liệu, vui lòng kiểm tra lại");

                    using (var dbContextTransaction = Context.Database.BeginTransaction())
                    {
                        try
                        {
                            int? shippingTypeID = item.Select(x => x.ShippingTypeVN).FirstOrDefault();
                            string note = item.Select(x => x.ExportRequestNote).FirstOrDefault();

                            ExportRequestTurn exReq = new ExportRequestTurn
                            {
                                UID = users.Id,
                                TotalPriceVND = info.TotalPriceVND,
                                TotalPriceCNY = info.TotalPriceCNY,
                                TotalWeight = info.TotalWeight,
                                Note = note,
                                ShippingTypeInVNId = shippingTypeID,
                                TotalPackage = item.Count,

                                //Thanh toán bằng ví: Type = 2, Status = 2
                                //Thanh toán tại kho: Type = 0, Status 1
                                Status = typePayment == 2 ? 2 : 1,
                                Type = typePayment, //0: Chưa thanh toán, 1: Thanh toán bằng ví, 2: Thanh toán trực tiếp (ở đây là 2 0)

                                OutStockDate = currentDate //Ngày xuất kho
                            };

                            await unitOfWork.Repository<ExportRequestTurn>().CreateAsync(exReq);
                            await unitOfWork.SaveAsync(); //Để lấy ID

                            foreach (var jtem in item)
                            {
                                var package = unitOfWork.Repository<SmallPackage>().GetQueryable().Where(x => x.Id == jtem.SmallPackageId).FirstOrDefault();
                                if (package == null && package.Status != 3) //Cái này chưa hiểu
                                    continue;
                                var check = await requestOutStockService.GetSingleAsync(x => x.SmallPackageId == package.Id);
                                if (check != null) //Có tồn tại rồi thì thôi
                                    continue;

                                package.DateOutWarehouse = currentDate;

                                await unitOfWork.Repository<RequestOutStock>().CreateAsync(new RequestOutStock
                                {
                                    SmallPackageId = package.Id,
                                    Status = 1,
                                    ExportRequestTurnId = exReq.Id,
                                    Deleted = false,
                                    Active = true,
                                    Created = currentDate,
                                    CreatedBy = users.UserName
                                });

                                jtem.TotalPriceVND = info.TotalPriceVND;
                                unitOfWork.Repository<TransportationOrder>().Update(jtem);

                                unitOfWork.Repository<SmallPackage>().Update(package);

                                await unitOfWork.SaveAsync();
                                await dbContextTransaction.CommitAsync();
                            }

                            //Trừ tiền trong ví (chỉ thanh toán bằng ví thì mới cần cái này)
                            if (typePayment == 2) //Thanh toán bằng ví
                            {
                                users.Wallet -= info.TotalPriceVND;
                                users.Updated = currentDate;
                                users.UpdatedBy = users.UserName;
                                unitOfWork.Repository<Users>().Update(users);

                                //Lịch sử của ví
                                await unitOfWork.Repository<HistoryPayWallet>().CreateAsync(new HistoryPayWallet
                                {
                                    UID = users.Id,
                                    MainOrderId = 0,
                                    Amount = info.TotalPriceVND,
                                    Content = string.Format("{0} đã thanh toán đơn hàng vận chuyển hộ.", users.UserName),
                                    MoneyLeft = users.Wallet,
                                    Type = (int?)DauCongVaTru.Tru,
                                    TradeType = (int?)HistoryPayWalletContents.ThanhToanVanChuyenHo,
                                    Deleted = false,
                                    Active = true,
                                    Created = currentDate,
                                    CreatedBy = users.UserName
                                });
                            }


                        }
                        catch (Exception ex)
                        {
                            await dbContextTransaction.RollbackAsync();
                            throw new Exception(ex.Message);
                        }
                    }
                    break;
                default:
                    break;
            }
            return true;
        }

        /// <summary>
        /// Tính lại tiền khi thay đổi SmallPackage
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public async Task<TransportationOrder> PriceAdjustment(TransportationOrder item)
        {
            var config = await unitOfWork.Repository<NhapHangV2.Entities.Configurations>().GetQueryable().FirstOrDefaultAsync();
            var smallPackages = item.SmallPackages;
            var user = await unitOfWork.Repository<Users>().GetQueryable().Where(e => !e.Deleted && e.Id == item.UID).FirstOrDefaultAsync();
            var userLevel = await unitOfWork.Repository<UserLevel>().GetQueryable().Where(e => !e.Deleted && e.Id == user.LevelId).FirstOrDefaultAsync();
            decimal? ckFeeWeight = userLevel == null ? 1 : userLevel.FeeWeight;
            item.FeeWeightCK = ckFeeWeight;
            decimal? totalWeight = smallPackages.Sum(e => e.PayableWeight);
            var warehouseFee = await unitOfWork.Repository<WarehouseFee>().GetQueryable().Where(e => !e.Deleted
                && e.WarehouseFromId == item.WareHouseFromId
                && e.WarehouseId == item.WareHouseId
                && e.ShippingTypeToWareHouseId == item.ShippingTypeId
                && e.IsHelpMoving == true
                && totalWeight >= e.WeightFrom && totalWeight <= e.WeightTo).FirstOrDefaultAsync();
            decimal? warehouseFeePrice = warehouseFee == null ? 1 : warehouseFee.Price;
            if (user.FeeTQVNPerWeight > 0)
            {
                warehouseFeePrice = user.FeeTQVNPerWeight;
            }
            decimal? feeWeight = 0;

            feeWeight = totalWeight * warehouseFeePrice;
            smallPackages.ForEach(e => { e.PriceWeight = warehouseFeePrice; e.DonGia = warehouseFeePrice; e.TotalPrice = totalWeight * warehouseFeePrice; });

            decimal? feeWeightDiscount = feeWeight * ckFeeWeight / 100;
            feeWeight -= feeWeightDiscount;

            if (item.TotalPriceVND == null)
            {
                item.TotalPriceVND = feeWeight + (item.CODFee ?? 0) + (item.IsCheckProductPrice ?? 0) + (item.IsPackedPrice ?? 0) + (item.InsuranceMoney ?? 0);
            }
            else
            {
                if (item.DeliveryPrice != feeWeight)
                {
                    item.TotalPriceVND = item.TotalPriceVND - item.DeliveryPrice + feeWeight;
                }
            }
            if (user.Currency != null && user.Currency > 0)
                item.TotalPriceCNY = item.TotalPriceVND / user.Currency;
            else
                item.TotalPriceCNY = item.TotalPriceVND / config.AgentCurrency;
            item.FeeWeightPerKg = warehouseFeePrice;
            item.DeliveryPrice = feeWeight;
            return item;
        }

        public async Task<bool> UpdateTransportationOrder(List<int> listId, int userId)
        {
            DateTime currentDate = DateTime.Now;
            decimal totalMustPay = 0;
            string userName = LoginContext.Instance.CurrentUser.UserName;
            var users = await unitOfWork.Repository<Users>().GetQueryable().Where(x => x.UserName == userName).FirstOrDefaultAsync();
            decimal wallet = users.Wallet ?? 0;

            if (!listId.Any())
                throw new KeyNotFoundException("Mã đơn ký gửi không tồn tại");
            var transportOrders = await this.GetAsync(x => !x.Deleted && x.Active && (listId.Contains(x.Id)));
            int checkStatus = 0;

            using (var dbContextTransaction = Context.Database.BeginTransaction())
            {
                try
                {
                    checkStatus = transportOrders.Where(x => x.Status == (int?)StatusGeneralTransportationOrder.VeKhoVN).Count();
                    if (transportOrders.Count() != checkStatus)
                        throw new AppException("Đơn ký gửi chưa thể thanh toán");
                    totalMustPay = transportOrders.Sum(x => x.TotalPriceVND + x.WarehouseFee) ?? 0;
                    if (wallet < totalMustPay)
                        throw new AppException("Số dư trong tài khoản không đủ. Vui lòng nạp thêm tiền");

                    foreach (var item in transportOrders)
                    {
                        decimal feeWarehouse = item.WarehouseFee ?? 0;
                        decimal totalPriceVND = item.TotalPriceVND ?? 0;
                        decimal moneyLeft = totalPriceVND + feeWarehouse;

                        users.Wallet -= moneyLeft;

                        users.Updated = currentDate;
                        users.UpdatedBy = userName;
                        unitOfWork.Repository<Users>().Update(users);

                        item.Status = (int?)StatusGeneralTransportationOrder.DaThanhToan;
                        item.DateExport = currentDate;
                        item.Updated = currentDate;
                        item.UpdatedBy = userName;

                        unitOfWork.Repository<TransportationOrder>().Update(item);

                        //Thêm lịch sử của ví tiền
                        await unitOfWork.Repository<HistoryPayWallet>().CreateAsync(new HistoryPayWallet()
                        {
                            UID = users.Id,
                            MainOrderId = item.Id,
                            Amount = moneyLeft,
                            Content = string.Format("{0} đã thanh toán đơn ký gửi: {1}.", users.UserName, item.Id),
                            MoneyLeft = wallet - moneyLeft,
                            Type = (int?)DauCongVaTru.Tru,
                            TradeType = (int?)HistoryPayWalletContents.ThanhToanHoaDon,
                            Deleted = false,
                            Active = true,
                            CreatedBy = users.UserName,
                            Created = currentDate
                        });

                        //Thông báo đơn hàng được thanh toán
                        var notificationSettingTT = await notificationSettingService.GetByIdAsync(11);
                        var notiTemplate = await notificationTemplateService.GetByIdAsync(15);
                        notiTemplate.Content = "Đơn ký gửi {0} đã được thanh toán";
                        var emailTemplate = await sMSEmailTemplateService.GetByCodeAsync("ADHDTT");
                        string subject = emailTemplate.Subject;
                        string emailContent = string.Format(emailTemplate.Body); //Thông báo Email
                        await sendNotificationService.SendNotification(notificationSettingTT, notiTemplate, item.Id.ToString(), $"/manager/deposit/deposit-list/{item.Id}", "", null, subject, emailContent);

                    }

                    await unitOfWork.SaveAsync();
                    await dbContextTransaction.CommitAsync();
                }
                catch (AppException ex)
                {
                    await dbContextTransaction.RollbackAsync();
                    throw new AppException(ex.Message);
                }
                return true;
            }
        }

        public async Task<AmountStatistic> GetTotalOrderPriceByUID(int UID)
        {
            var transportationOrders = await unitOfWork.Repository<TransportationOrder>().GetQueryable().Where(x => x.UID == UID && !x.Deleted).ToListAsync();
            return new AmountStatistic
            {
                TotalOrderPrice = transportationOrders.Sum(x => x.TotalPriceVND) ?? 0,
            };
        }

        public TransportationsInfor GetTransportationsInfor(TransportationOrderSearch transportationOrderSearch)
        {
            var storeService = serviceProvider.GetRequiredService<IStoreSqlService<TransportationsInfor>>();
            List<SqlParameter> sqlParameters = new List<SqlParameter>();
            sqlParameters.Add(new SqlParameter("@UID", transportationOrderSearch.UID));
            sqlParameters.Add(new SqlParameter("@RoleID", transportationOrderSearch.RoleID));
            SqlParameter[] parameters = sqlParameters.ToArray();
            var data = storeService.GetDataFromStore(parameters, "GetTransportationsInfor");
            return data.FirstOrDefault();
        }

        public TransportationsAmount GetTransportationsAmount(int UID)
        {
            var storeService = serviceProvider.GetRequiredService<IStoreSqlService<TransportationsAmount>>();
            List<SqlParameter> sqlParameters = new List<SqlParameter>();
            sqlParameters.Add(new SqlParameter("@UID", UID));
            SqlParameter[] parameters = sqlParameters.ToArray();
            var data = storeService.GetDataFromStore(parameters, "GetTransportationsAmount");
            return data.FirstOrDefault();

        }

        public class CheckWarehouse
        {
            public int WareHouseFromId { get; set; }
            public int WareHouseId { get; set; }
            public int ShippingTypeId { get; set; }
            public decimal TotalWeight { get; set; }
            public List<Package> Packages { get; set; } = new List<Package>();
        }

        public class Package
        {
            public int TransportationId { get; set; }
            public decimal Weight { get; set; }
        }
    }
}
