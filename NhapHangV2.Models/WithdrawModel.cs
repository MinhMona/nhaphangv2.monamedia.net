using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.Models
{
    public class WithdrawModel : AppDomainModel
    {
        /// <summary>
        /// UID
        /// </summary>
        public int? UID { get; set; }

        /// <summary>
        /// UserName
        /// </summary>
        public string UserName { get; set; }

        /// <summary>
        /// Họ tên khách
        /// </summary>
        public string FullName { get; set; }

        /// <summary>
        /// Số tiền nạp
        /// </summary>
        public decimal? Amount { get; set; }

        /// <summary>
        /// Trạng thái
        /// </summary>
        public int? Status { get; set; }

        /// <summary>
        /// Tên trạng thái
        /// </summary>
        public string StatusName
        {
            get
            {
                switch (Status)
                {
                    case (int)WalletStatus.DangChoDuyet:
                        return "Đang chờ duyệt";
                    case (int)WalletStatus.DaDuyet:
                        return "Đã duyệt";
                    case (int)WalletStatus.Huy:
                        return "Hủy";
                    default:
                        return string.Empty;
                }
            }
        }

        /// <summary>
        /// Số đơn 
        /// </summary>
        public int? TotalStatus { get; set; }
        /// <summary>
        /// Số đơn chờ duyệt
        /// </summary>
        public int? TotalStatus1 { get; set; }

        /// <summary>
        /// Số đơn đã duyệt
        /// </summary>
        public int? TotalStatus2 { get; set; }

        /// <summary>
        /// Số đơn đã hủy
        /// </summary>
        public int? TotalStatus3 { get; set; }

        /// <summary>
        /// Tổng số tiền
        /// </summary>
        public decimal? TotalAmount { get; set; }

        /// <summary>
        /// Tổng số tiền đã duyệt
        /// </summary>
        public decimal? TotalAmount2 { get; set; }

        /// <summary>
        /// Tổng số tiền chờ duyệt
        /// </summary>
        public decimal? TotalAmount1 { get; set; }

        /// <summary>
        /// Nội dung
        /// </summary>
        public string Note { get; set; }

        /// <summary>
        /// Loại
        /// </summary>
        public int? Type { get; set; }

        /// <summary>
        /// Tên loại
        /// </summary>
        public string TypeName
        {
            get
            {
                switch (Type)
                {
                    case (int)WithdrawTypes.RutTien:
                        return "Rút tiền";
                    case (int)WithdrawTypes.NapTien:
                        return "Nạp tiền";
                    default:
                        return string.Empty;
                }
            }
        }

        /// <summary>
        /// Ngân hàng
        /// </summary>
        public string BankAddress { get; set; }

        /// <summary>
        /// Số tài khoản
        /// </summary>
        public string BankNumber { get; set; }

        /// <summary>
        /// Người hưởng
        /// </summary>
        public string Beneficiary { get; set; }

    }
}
