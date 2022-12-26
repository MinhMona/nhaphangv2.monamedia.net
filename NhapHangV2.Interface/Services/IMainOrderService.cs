using NhapHangV2.Entities;
using NhapHangV2.Entities.Search;
using NhapHangV2.Interface.Services.DomainServices;
using NhapHangV2.Models;
using NhapHangV2.Models.ExcelModels;
using NhapHangV2.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Interface.Services
{
    public interface IMainOrderService : IDomainService<MainOrder, MainOrderSearch>
    {
        Task<bool> UpdateStaff(MainOrder item);

        Task<bool> UpdateMainOrder(List<int> listId, int status, int userId);

        Task<bool> CreateOrder(List<MainOrder> listData, bool isAnother);

        Task<bool> Payment(int id, int paymentType, int paymentMethod, decimal amount, string note);

        Task<MainOrder> PriceAdjustment(MainOrder item);
        Task<AmountStatistic> GetTotalOrderPriceByUID(int UID);
        MainOrdersInfor GetMainOrdersInfor(int UID, int orderType);
        MainOrdersAmount GetMainOrdersAmount(int UID, int orderType);
        Task<bool> UpdateStatus(int ID, int status);
        Task<bool> UpdateIsCheckNotiPrice(MainOrder mainOrder);
        void UpdateMainOrderFromSql(string commandText);
        NumberOfOrders GetNumberOfOrders(MainOrderSearch mainOrderSearch);
        byte[] GetMainOrdersExcel(MainOrderSearch mainOrderSearch);
    }
}
