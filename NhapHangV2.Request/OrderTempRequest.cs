using NhapHangV2.Request.DomainRequests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Request
{
    public class OrderTempRequest : AppDomainRequest
    {
        public string? title_origin { get; set; }

        public string? title_translated { get; set; }

        public decimal? price_origin { get; set; }

        public decimal? price_promotion { get; set; }

        public string? property { get; set; }

        public string? image_model { get; set; }

        public string? property_translated { get; set; }

        public string? image_origin { get; set; }

        public string? seller_id { get; set; }

        public string? shop_id { get; set; }

        public string? shop_name { get; set; }

        public string? wangwang { get; set; }

        public int? quantity { get; set; }

        public int? stock { get; set; }

        public string? location_sale { get; set; }

        public string? site { get; set; }

        public string? item_id { get; set; }

        public string? link_origin { get; set; }

        public string? weight { get; set; }

        public string? brand { get; set; }

        public string? category_name { get; set; }

        public string? category_id { get; set; }

        public string? tool { get; set; }

        public string? version { get; set; }

        public bool? is_translate { get; set; }

        public string? pricestep { get; set; }

        public string? error { get; set; }

        /// <summary>
        /// Số lượng sản phẩm tối thiểu
        /// </summary>
        public int? MinimumQuantity { get; set; }

        ////public int? OrderShopTempId { get; set; }

        ///// <summary>
        ///// Tên sản phẩm (Gốc)
        ///// </summary>
        //public string? TitleOrigin { get; set; }

        ///// <summary>
        ///// Tên sản phẩm (Dịch)
        ///// </summary>
        //public string? TitleTranslated { get; set; }

        ///// <summary>
        ///// Giá gốc (tệ)
        ///// </summary>
        //public decimal? PriceOrigin { get; set; }

        ///// <summary>
        ///// Giá khuyến mãi (tệ)
        ///// </summary>
        //public decimal? PricePromotion { get; set; }

        ///// <summary>
        ///// Thông số (Dịch)
        ///// </summary>
        //public string? PropertyTranslated { get; set; }

        ///// <summary>
        ///// Thông số (Gốc)
        ///// </summary>
        //public string? Property { get; set; }

        ///// <summary>
        ///// Id của shop trên website
        ///// </summary>
        //public string? ShopId { get; set; }

        ///// <summary>
        ///// Tên shop trên website
        ///// </summary>
        //public string? ShopName { get; set; }

        ///// <summary>
        ///// Id người bán
        ///// </summary>
        //public string? SellerId { get; set; }

        ///// <summary>
        ///// Cái gì của shop ấy
        ///// </summary>
        //public string? Wangwang { get; set; }

        ///// <summary>
        ///// Số lượng
        ///// </summary>
        //public int? Quantity { get; set; }

        ///// <summary>
        ///// Hàng trong kho
        ///// </summary>
        //public int? Stock { get; set; }

        ///// <summary>
        ///// Địa chỉ của shop
        ///// </summary>
        //public string? LocationSale { get; set; }

        ///// <summary>
        ///// Website
        ///// </summary>
        //public string? Site { get; set; }

        ///// <summary>
        ///// Id của sản phẩm trên website
        ///// </summary>
        //public string? ItemId { get; set; }

        ///// <summary>
        ///// Link của sản phẩm
        ///// </summary>
        //public string? LinkOrigin { get; set; }

        ///// <summary>
        ///// Cân nặng
        ///// </summary>
        //public decimal? Weight { get; set; }

        ///// <summary>
        ///// Ghi chú sản phẩm
        ///// </summary>
        //public string? Brand { get; set; }

        ///// <summary>
        ///// Extension (Danh mục)
        ///// </summary>
        //public string? CategoryName { get; set; }

        ///// <summary>
        ///// Extension (Id Danh mục)
        ///// </summary>
        //public int? CategoryId { get; set; }

        ///// <summary>
        ///// Extension (Công cụ)
        ///// </summary>
        //public string? Tool { get; set; }

        ///// <summary>
        ///// Extension (Phiên bản)
        ///// </summary>
        //public string? Version { get; set; }

        ///// <summary>
        ///// Extension (Lỗi)
        ///// </summary>
        //public string? Error { get; set; }

        ///// <summary>
        ///// Dịch
        ///// </summary>
        //public bool? IsTranslate { get; set; }

        ///// <summary>
        ///// Bước nhảy
        ///// </summary>
        //public string? StepPrice { get; set; }

        ///// <summary>
        ///// Có xài mà không biết là gì
        ///// </summary>
        //public string? Comment { get; set; }

        //public string? OuterId { get; set; }

        //public string? DataValue { get; set; }

        //public string? ImageOrigin { get; set; }
    }
}
