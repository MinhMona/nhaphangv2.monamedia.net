using NhapHangV2.Entities.Auth;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace NhapHangV2.Entities
{
    public class Users : DomainEntities.AppDomain
    {
        /// <summary>
        /// UserName
        /// </summary>
        [Required]
        [StringLength(50)]
        public string UserName { get; set; } = string.Empty;

        /// <summary>
        /// Ảnh đại diện
        /// </summary>
        public string AvatarIMG { get; set; } = string.Empty;

        /// <summary>
        /// Tên
        /// </summary>
        [StringLength(200)]
        public string FirstName { get; set; } = string.Empty;

        /// <summary>
        /// Họ
        /// </summary>
        [StringLength(200)]
        public string LastName { get; set; } = string.Empty;

        /// <summary>
        /// Họ và tên
        /// </summary>
        [StringLength(200)]
        public string FullName { get; set; } = string.Empty;

        /// <summary>
        /// Số điện thoại
        /// </summary>
        [StringLength(20)]
        public string Phone { get; set; } = string.Empty;

        /// <summary>
        /// Email
        /// </summary>
        [StringLength(50)]
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// Địa chỉ
        /// </summary>
        [StringLength(1000)]
        public string Address { get; set; } = string.Empty;

        /// <summary>
        /// Trạng thái (1: Đã kích hoạt, 2: Chưa kích hoạt, 3: Đang bị khóa)
        /// </summary>
        public int? Status { get; set; } = 1; //Mặc định là đã kích hoạt

        /// <summary>
        /// Ngày sinh
        /// </summary>
        public DateTime? Birthday { get; set; }

        /// <summary>
        /// Phải là admin không
        /// </summary>
        public bool IsAdmin { get; set; } = false;

        /// <summary>
        /// Mật khẩu người dùng
        /// </summary>
        [StringLength(4000)]
        public string Password { get; set; } = string.Empty;

        /// <summary>
        /// Token đăng nhập
        /// </summary>
        public string Token { get; set; } = string.Empty;

        /// <summary>
        /// Thời gian hết hạn token
        /// </summary>
        public DateTime? ExpiredDate { get; set; }

        /// <summary>
        /// Giới tính
        /// 0 => Nữ
        /// 1 => Nam
        /// </summary>
        public int? Gender { get; set; } = 0;

        /// <summary>
        /// Cờ kiểm tra OTP của user
        /// </summary>
        [DefaultValue(false)]
        public bool IsCheckOTP { get; set; } = false;

        /// <summary>
        /// Cờ check login = facebook
        /// </summary>
        [DefaultValue(false)]
        public bool IsLoginFaceBook { get; set; } = false;

        /// <summary>
        /// Cờ check login = google
        /// </summary>
        [DefaultValue(false)]
        public bool IsLoginGoogle { get; set; } = false;

        #region Extension Properties

        /// <summary>
        /// Cờ xét reset mật khẩu
        /// </summary>
        [NotMapped]
        public bool IsResetPassword { get; set; } = false;

        /// <summary>
        /// ID nhóm người dùng được chọn
        /// </summary>
        [NotMapped]
        public int UserGroupId { get; set; } = 0;

        /// <summary>
        /// Tên nhóm người dùng được chọn
        /// </summary>
        [NotMapped]
        public string UserGroupName { get; set; } = string.Empty;

        #endregion

        /// <summary>
        /// Cấp người dùng
        /// </summary>
        public int? LevelId { get; set; } = 0;

        /// <summary>
        /// Số dư (VNĐ)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")] 
        public decimal? Wallet { get; set; } = 0;

        /// <summary>
        /// ID nhân viên kinh doanh
        /// </summary>
        public int? SaleId { get; set; } = 0;

        /// <summary>
        /// ID nhân viên đặt hàng
        /// </summary>
        public int? DatHangId { get; set; } = 0;

        /// <summary>
        /// Số dư (Tệ)
        /// </summary>
        [Column(TypeName = "decimal(18,2)")] 
        public decimal? WalletCNY { get; set; } = 0;

        /// <summary>
        /// Kho TQ
        /// </summary>
        public int? WarehouseFrom { get; set; } = 0;

        /// <summary>
        /// Kho VN
        /// </summary>
        public int? WarehouseTo { get; set; } = 0;

        /// <summary>
        /// Tỉ giá riêng (Tệ)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")] 
        public decimal? Currency { get; set; } = 0;

        /// <summary>
        /// Phí mua hàng riêng (%)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")] 
        public decimal? FeeBuyPro { get; set; } = 0;

        /// <summary>
        /// Phí cân nặng riêng (VNĐ/KG)
        /// </summary>
        [Column(TypeName = "decimal(18,1)")] 
        public decimal? FeeTQVNPerWeight { get; set; } = 0;

        /// <summary>
        /// Phần trăm đặt cọc (%)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")] 
        public decimal? Deposit { get; set; } = 0;

        /// <summary>
        /// Phương thức vận chuyển
        /// </summary>
        public int? ShippingType { get; set; } = 0;

        /// <summary>
        /// One Signal Player ID
        /// </summary>
        public string OneSignalPlayerID { get; set; }

        /// <summary>
        /// Tổng nạp
        /// </summary>
        [NotMapped]
        public decimal SumAmount { get; set; } = 0;

        /// <summary>
        /// Tổng đơn mua hộ
        /// </summary>
        [NotMapped]
        public decimal TotalMainOrder { get; set; } = 0;

        /// <summary>
        /// Tổng đơn vận chuyển hộ
        /// </summary>
        [NotMapped]
        public decimal TotalTransportationOrder { get; set; } = 0;

        /// <summary>
        /// Tổng đơn thanh toán hộ
        /// </summary>
        [NotMapped]
        public decimal TotalPayHelp { get; set; } = 0;

        /// <summary>
        /// Cờ check có sự thay đổi tỷ giá
        /// </summary>
        [NotMapped]
        public bool IsChangeCurrency { get; set; } = false;

        /// <summary>
        /// id đăng nhập google, facebook
        /// </summary>
        [StringLength(100)]
        public string FireBaseID { get; set; } = string.Empty;

        //public string FeeTQVNPerVolume { get; set; } = string.Empty;

        //public string TienTichLuy { get; set; } = string.Empty;

        //public DateTime? DateUpLevel { get; set; }
    }
}
