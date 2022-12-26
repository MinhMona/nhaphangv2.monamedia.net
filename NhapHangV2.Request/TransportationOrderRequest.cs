using NhapHangV2.Request.DomainRequests;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Request
{
    public class TransportationOrderRequest : AppDomainRequest
    {

        /// <summary>
        /// ID khách hàng
        /// </summary>
        public int? UID { get; set; }

        /// <summary>
        /// Kho TQ (POST - PUT)
        /// </summary>
        public int? WareHouseFromId { get; set; }

        /// <summary>
        /// Kho đích (POST - PUT)
        /// </summary>
        public int? WareHouseId { get; set; }

        /// <summary>
        /// Phương thức vận chuyển (POST - PUT)
        /// </summary>
        public int? ShippingTypeId { get; set; }

        /// <summary>
        /// Danh sách kiện ký gửi (POST)
        /// </summary>
        public List<SmallPackageRequest>? SmallPackages { get; set; }

        /// <summary>
        /// Phụ phí hàng đặc biệt (tệ) - Lấy từ SmallPackage (PUT)
        /// </summary>
        public decimal? AdditionFeeCNY { get; set; }

        /// <summary>
        /// Phụ phí hàng đặc biệt (VNĐ) - Lấy từ SmallPackage (PUT)
        /// </summary>
        public decimal? AdditionFeeVND { get; set; }

        /// <summary>
        /// Cước vật tư (tệ) - Lấy từ SmallPackage (PUT)
        /// </summary>
        public decimal? SensorFeeCNY { get; set; }

        /// <summary>
        /// Cước vật tư (VNĐ) - Lấy từ SmallPackage (PUT)
        /// </summary>
        public decimal? SensorFeeVND { get; set; }

        /// <summary>
        /// Ghi chú (PUT)
        /// </summary>
        public string? Note { get; set; }

        /// <summary>
        /// Ghi chú của nhân viên (PUT)
        /// </summary>
        public string? StaffNote { get; set; }

        /// <summary>
        /// Trạng thái (PUT)
        /// </summary>
        public int Status { get; set; }

        /// <summary>
        /// Tiền cân / Kg
        /// </summary>
        [Column(TypeName = "decimal(18,1)")]
        public decimal? FeeWeightPerKg { get; set; } = 0;

        /// <summary>
        /// Phí vận chuyển(VNĐ)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? DeliveryPrice { get; set; } = 0;

        /// <summary>
        /// Kiểm đếm
        /// </summary>
        public bool? IsCheckProduct { get; set; } = false;

        /// <summary>
        /// Phí kiểm đếm (VNĐ)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? IsCheckProductPrice { get; set; } = 0;

        /// <summary>
        /// Đóng gỗ
        /// </summary>
        public bool? IsPacked { get; set; } = false;

        /// <summary>
        /// Phí đóng gỗ (VNĐ)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? IsPackedPrice { get; set; } = 0;

        /// <summary>
        /// Bảo hiểm
        /// </summary>
        public bool? IsInsurance { get; set; } = false;

        /// <summary>
        /// Phí bảo hiểm
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? InsuranceMoney { get; set; } = 0;

        /// <summary>
        /// Phí ship nội địa TQ
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? CODFee { get; set; } = 0;

        /// <summary>
        /// Phí ship nội địa TQ-Tệ
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? CODFeeTQ { get; set; } = 0;

        /// <summary>
        /// ID Saler tạo dùm
        /// </summary>
        public int? SalerID { get; set; }

        /// <summary>
        /// Ghi chú hủy đơn
        /// </summary>
        public string? CancelReason { get; set; }

    }

    //public class ShippingOrder
    //{
    //    /// <summary>
    //    /// Mã kiện
    //    /// </summary>
    //    public int ID { get; set; }

    //    /// <summary>
    //    /// Mã kiện
    //    /// </summary>
    //    public string BarCode { get; set; }

    //    /// <summary>
    //    /// Ghi chú
    //    /// </summary>
    //    public string? Note { get; set; }

    //}
}
