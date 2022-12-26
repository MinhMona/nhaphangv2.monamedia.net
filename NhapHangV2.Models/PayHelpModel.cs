using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.Models
{
    public class PayHelpModel : AppDomainModel
    {
        /// <summary>
        /// UserName
        /// </summary>
        public string UserName { get; set; }

        /// <summary>
        /// Ghi chú
        /// </summary>
        public string Note { get; set; }

        /// <summary>
        /// Tổng tiền
        /// </summary>
        public decimal? TotalPrice { get; set; }

        /// <summary>
        /// Tổng tiền (VNĐ)
        /// </summary>
        public decimal? TotalPriceVND { get; set; }

        /// <summary>
        /// Tỉ giá
        /// </summary>
        public decimal? Currency { get; set; }

        /// <summary>
        /// Đã trả
        /// </summary>
        public decimal? Deposit { get; set; }

        /// <summary>
        /// Tỉ giá hệ thống
        /// </summary>
        public decimal? CurrencyConfig { get; set; }

        /// <summary>
        /// Trạng thái
        /// </summary>
        public int? Status { get; set; }

        /// <summary>
        /// Hoàn thiện
        /// </summary>
        public bool? IsComplete { get; set; }

        /// <summary>
        /// Tên trạng thái
        /// </summary>
        public string StatusName
        {
            get
            {
                if (IsComplete == true)
                    return "Đang hoàn thiện";
                switch (Status)
                {
                    case (int)StatusPayHelp.ChuaThanhToan:
                        return "Chưa thanh toán";
                    case (int)StatusPayHelp.DaThanhToan:
                        return "Đã thanh toán";
                    case (int)StatusPayHelp.DaHuy:
                        return "Đã hủy";
                    case (int)StatusPayHelp.DaHoanThanh:
                        return "Đã hoàn thành";
                    case (int)StatusPayHelp.DaXacNhan:
                        return "Xác nhận";
                    default:
                        return string.Empty;
                }
            }
        }

        public decimal? TotalPriceVNDGiaGoc { get; set; }

        /// <summary>
        /// Hóa đơn thanh toán hộ
        /// </summary>
        public List<PayHelpDetailModel> PayHelpDetails { get; set; }

        /// <summary>
        /// Lịch sử thanh toán
        /// </summary>
        public List<HistoryServicesModel> HistoryServices { get; set; }
    }
}
