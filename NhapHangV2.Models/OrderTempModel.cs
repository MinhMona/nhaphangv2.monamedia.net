using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Models
{
    public class OrderTempModel : AppDomainModel
    {
        public int? UID { get; set; }

        public int? OrderShopTempId { get; set; }

        /// <summary>
        /// Tên sản phẩm (Gốc)
        /// </summary>
        public string TitleOrigin { get; set; }

        /// <summary>
        /// Tên sản phẩm (Dịch)
        /// </summary>
        public string TitleTranslated { get; set; }

        /// <summary>
        /// Giá gốc (tệ)
        /// </summary>
        public decimal? PriceOrigin { get; set; }

        /// <summary>
        /// Giá khuyến mãi (tệ)
        /// </summary>
        public decimal? PricePromotion { get; set; }

        /// <summary>
        /// Thông số (Dịch)
        /// </summary>
        public string PropertyTranslated { get; set; }

        /// <summary>
        /// Thông số (Gốc)
        /// </summary>
        public string Property { get; set; }

        /// <summary>
        /// Id của shop trên website
        /// </summary>
        public string ShopId { get; set; }

        /// <summary>
        /// Tên shop trên website
        /// </summary>
        public string ShopName { get; set; }

        /// <summary>
        /// Id người bán
        /// </summary>
        public string SellerId { get; set; }

        /// <summary>
        /// Cái gì của shop ấy
        /// </summary>
        public string Wangwang { get; set; }

        /// <summary>
        /// Số lượng
        /// </summary>
        public int? Quantity { get; set; }

        /// <summary>
        /// Hàng trong kho
        /// </summary>
        public int? Stock { get; set; }

        /// <summary>
        /// Địa chỉ của shop
        /// </summary>
        public string LocationSale { get; set; }

        /// <summary>
        /// Website
        /// </summary>
        public string Site { get; set; }

        /// <summary>
        /// Id của sản phẩm trên website
        /// </summary>
        public string ItemId { get; set; }

        /// <summary>
        /// Link của sản phẩm
        /// </summary>
        public string LinkOrigin { get; set; }

        /// <summary>
        /// Cân nặng
        /// </summary>
        public decimal? Weight { get; set; }

        /// <summary>
        /// Ghi chú sản phẩm
        /// </summary>
        public string Brand { get; set; }

        /// <summary>
        /// Extension (Danh mục)
        /// </summary>
        public string CategoryName { get; set; }

        /// <summary>
        /// Extension (Id Danh mục)
        /// </summary>
        public int? CategoryId { get; set; }

        /// <summary>
        /// Extension (Công cụ)
        /// </summary>
        public string Tool { get; set; }

        /// <summary>
        /// Extension (Phiên bản)
        /// </summary>
        public string Version { get; set; }

        /// <summary>
        /// Extension (Lỗi)
        /// </summary>
        public string Error { get; set; }

        /// <summary>
        /// Dịch
        /// </summary>
        public bool? IsTranslate { get; set; }

        /// <summary>
        /// Bước nhảy
        /// </summary>
        public string StepPrice { get; set; }

        /// <summary>
        /// Số lượng sản phẩm tối thiểu
        /// </summary>
        public int MinimumQuantity { get; set; }

        /// <summary>
        /// Có xài mà không biết là gì
        /// </summary>
        public string Comment { get; set; }

        public string OuterId { get; set; }

        public string DataValue { get; set; }

        public string ImageOrigin { get; set; }

        /// <summary>
        /// Tỉ giá (hoặc là Tỉ giá của User hoặc là Tỉ giá hệ thống)
        /// </summary>
        public decimal? Currency { get; set; }

        /// <summary>
        /// Đơn giá
        /// </summary>
        public decimal? UPriceBuy
        {
            get
            {
                if (PricePromotion > 0 && PricePromotion < PriceOrigin)
                    return PricePromotion;
                else
                    return PriceOrigin;
            }
        }

        /// <summary>
        /// Đơn giá (VNĐ)
        /// </summary>
        public decimal? UPriceBuyVN 
        { 
            get
            {
                if (PricePromotion > 0 && PricePromotion < PriceOrigin)
                    return PricePromotion * Currency;
                else
                    return PriceOrigin * Currency;
            }
        }

        /// <summary>
        /// Tiền hàng
        /// </summary>
        public decimal? EPriceBuy
        {
            get
            {
                if (PricePromotion > 0 && PricePromotion < PriceOrigin)
                    return PricePromotion * Quantity;
                else
                    return PriceOrigin * Quantity;
            }
        }

        /// <summary>
        /// Tiền hàng (VNĐ)
        /// </summary>
        public decimal? EPriceBuyVN 
        {
            get
            {
                if (PricePromotion > 0 && PricePromotion < PriceOrigin)
                    return PricePromotion * Quantity * Currency;
                else
                    return PriceOrigin * Quantity * Currency;
            }
        }

        /// <summary>
        /// Tổng tiền tất cả đơn hàng
        /// </summary>
        public decimal? MaxEPriceBuyVN { get; set; }
    }
}
