using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities
{
    public class OrderTemp : DomainEntities.AppDomain
    {
        public int? UID { get; set; } = 0;

        public int? OrderShopTempId { get; set; } = 0;

        /// <summary>
        /// Tên sản phẩm (Gốc)
        /// </summary>
        public string TitleOrigin { get; set; } = string.Empty;

        /// <summary>
        /// Tên sản phẩm (Dịch)
        /// </summary>
        public string TitleTranslated { get; set; } = string.Empty;

        /// <summary>
        /// Giá gốc (tệ)
        /// </summary>
        [Column(TypeName = "decimal(18,2)")]
        public decimal? PriceOrigin { get; set; } = 0;

        /// <summary>
        /// Giá khuyến mãi (tệ)
        /// </summary>
        [Column(TypeName = "decimal(18,2)")]
        public decimal? PricePromotion { get; set; } = 0;

        /// <summary>
        /// Thông số (Dịch)
        /// </summary>
        public string PropertyTranslated { get; set; } = string.Empty;

        /// <summary>
        /// Thông số (Gốc)
        /// </summary>
        public string Property { get; set; } = string.Empty;

        /// <summary>
        /// Id của shop trên website
        /// </summary>
        public string ShopId { get; set; } = string.Empty;

        /// <summary>
        /// Tên shop trên website
        /// </summary>
        public string ShopName { get; set; } = string.Empty;

        /// <summary>
        /// Id người bán
        /// </summary>
        public string SellerId { get; set; } = string.Empty;

        /// <summary>
        /// Cái gì của shop ấy
        /// </summary>
        public string Wangwang { get; set; } = string.Empty;

        /// <summary>
        /// Số lượng
        /// </summary>
        public int? Quantity { get; set; } = 0;

        /// <summary>
        /// Hàng trong kho
        /// </summary>
        public int? Stock { get; set; } = 0;

        /// <summary>
        /// Địa chỉ của shop
        /// </summary>
        public string LocationSale { get; set; } = string.Empty;

        /// <summary>
        /// Website
        /// </summary>
        public string Site { get; set; } = string.Empty;

        /// <summary>
        /// Id của sản phẩm trên website
        /// </summary>
        public string ItemId { get; set; } = string.Empty;

        /// <summary>
        /// Link của sản phẩm
        /// </summary>
        public string LinkOrigin { get; set; } = string.Empty;

        /// <summary>
        /// Cân nặng
        /// </summary>
        [Column(TypeName = "decimal(18,2)")]
        public decimal? Weight { get; set; } = 0;

        /// <summary>
        /// Ghi chú sản phẩm
        /// </summary>
        public string Brand { get; set; } = string.Empty;

        /// <summary>
        /// Extension (Danh mục)
        /// </summary>
        public string CategoryName { get; set; } = string.Empty;

        /// <summary>
        /// Extension (Id Danh mục)
        /// </summary>
        public int? CategoryId { get; set; } = 0;

        /// <summary>
        /// Extension (Công cụ)
        /// </summary>
        public string Tool { get; set; } = string.Empty;

        /// <summary>
        /// Extension (Phiên bản)
        /// </summary>
        public string Version { get; set; } = string.Empty;

        /// <summary>
        /// Extension (Lỗi)
        /// </summary>
        public string Error { get; set; } = string.Empty;

        /// <summary>
        /// Dịch
        /// </summary>
        public bool? IsTranslate { get; set; } = false;

        /// <summary>
        /// Bước nhảy
        /// </summary>
        public string StepPrice { get; set; } = string.Empty;

        /// <summary>
        /// Có xài mà không biết là gì
        /// </summary>
        public string Comment { get; set; } = string.Empty;

        public string OuterId { get; set; } = string.Empty;

        public string DataValue { get; set; } = string.Empty;

        /// <summary>
        /// Hình ảnh
        /// </summary>
        public string ImageOrigin { get; set; } = string.Empty;

        /// <summary>
        /// Số lượng sản phẩm tối thiểu
        /// </summary>
        public int MinimumQuantity { get; set; }

        /// <summary>
        /// Tỉ giá
        /// </summary>
        [NotMapped]
        public decimal? Currency { get; set; } = 0;

        /// <summary>
        /// Đơn giá
        /// </summary>
        [NotMapped]
        [Column(TypeName = "decimal(18,2)")]
        public decimal? UPriceBuy { get; set; } = 0;

        /// <summary>
        /// Đơn giá (VNĐ)
        /// </summary>
        [NotMapped]
        [Column(TypeName = "decimal(18,2)")]
        public decimal? UPriceBuyVN { get; set; } = 0;

        /// <summary>
        /// Tiền hàng
        /// </summary>
        [NotMapped]
        [Column(TypeName = "decimal(18,2)")]
        public decimal? EPriceBuy { get; set; } = 0;

        /// <summary>
        /// Tiền hàng (VNĐ)
        /// </summary>
        [NotMapped]
        [Column(TypeName = "decimal(18,2)")]
        public decimal? EPriceBuyVN { get; set; } = 0;

        /// <summary>
        /// Tổng tiền tất cả đơn hàng
        /// </summary>
        [NotMapped]
        [Column(TypeName = "decimal(18,2)")]
        public decimal? MaxEPriceBuyVN { get; set; } = 0;
    }
}
