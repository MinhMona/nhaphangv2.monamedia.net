﻿using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static NhapHangV2.Utilities.CoreContants;

namespace NhapHangV2.Models.Report
{
    public class MainOrderReportModel : AppDomainReportModel
    {
        /// <summary>
        /// UserName
        /// </summary>
        public string UserName { get; set; }

        /// <summary>
        /// Tên shop
        /// </summary>
        public string ShopName { get; set; }

        /// <summary>
        /// NV kinh doanh
        /// </summary>
        public string SalerUserName { get; set; }

        /// <summary>
        /// Phí ship TQ
        /// </summary>
        public decimal? FeeShipCN { get; set; }

        /// <summary>
        /// Phí ship TQ - VN
        /// </summary>
        public decimal? FeeWeight { get; set; }

        /// <summary>
        /// Phí mua hàng
        /// </summary>
        public decimal? FeeBuyPro { get; set; }

        /// <summary>
        /// Phí cân nặng
        /// </summary>
        public decimal? TQVNWeight { get; set; }

        /// <summary>
        /// Phí giao hàng tận nhà
        /// </summary>
        public decimal? IsFastDeliveryPrice { get; set; }

        /// <summary>
        /// Phí kiểm đếm
        /// </summary>
        public decimal? IsCheckProductPrice { get; set; }

        /// <summary>
        /// Phí đóng gỗ
        /// </summary>
        public decimal? IsPackedPrice { get; set; }

        /// <summary>
        /// Tổng tiền (VNĐ)
        /// </summary>
        public decimal? TotalPriceVND { get; set; }

        /// <summary>
        /// Tổng tiền thật
        /// </summary>
        public decimal? TotalPriceReal { get; set; } = 0;

        /// <summary>
        /// Tổng tiền hàng
        /// </summary>
        public decimal? PriceVND { get; set; } = 0;

        /// <summary>
        /// Đặt cọc
        /// </summary>
        public decimal? Deposit { get; set; }

        /// <summary>
        /// Còn lại
        /// </summary>
        public decimal? MustPay { get; set; } = 0;

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
                    case (int)StatusOrderContants.ChuaDatCoc:
                        return "Chưa đặt cọc";
                    case (int)StatusOrderContants.Huy:
                        return "Hủy";
                    case (int)StatusOrderContants.DaDatCoc:
                        return "Đã đặt cọc";
                    case (int)StatusOrderContants.ChoDuyetDon:
                        return "Chờ duyệt đơn";
                    case (int)StatusOrderContants.DaDuyetDon:
                        return "Đã duyệt đơn";
                    case (int)StatusOrderContants.DaMuaHang:
                        return "Đã mua hàng";
                    case (int)StatusOrderContants.DaVeKhoTQ:
                        return "Đã về kho TQ";
                    case (int)StatusOrderContants.DaVeKhoVN:
                        return "Đã về kho VN";
                    case (int)StatusOrderContants.ChoThanhToan:
                        return "Chờ thanh toán";
                    case (int)StatusOrderContants.KhachDaThanhToan:
                        return "Khách đã thanh toán";
                    case (int)StatusOrderContants.DaHoanThanh:
                        return "Đã hoàn thành";
                    default:
                        return string.Empty;
                }
            }
        }

        /// <summary>
        /// Tiền lời
        /// </summary>
        public decimal? Profit { get; set; }

        /// <summary>
        /// Phí bảo hiểm
        /// </summary>
        public decimal? InsuranceMoney { get; set; }

        /// <summary>
        /// Phí lưu kho
        /// </summary>
        public decimal? FeeInWareHouse { get; set; }

        /// <summary>
        /// Tổng tiền đơn hàng
        /// </summary>
        public decimal? MaxTotalPriceVND { get; set; }

        /// <summary>
        /// Tổng tiền cần thanh toán
        /// </summary>
        public decimal? MaxMustPay { get; set; }

        /// <summary>
        /// Tổng tiền thật
        /// </summary>
        public decimal? MaxTotalPriceReal { get; set; } 

        /// <summary>
        /// Tổng tiền lời
        /// </summary>
        public decimal? MaxProfit { get; set; }

        /// <summary>
        /// Tổng tiền hàng
        /// </summary>
        public decimal? MaxPriceVND { get; set; }

        /// <summary>
        /// Tổng tiền ship TQ
        /// </summary>
        public decimal? MaxFeeShipCN { get; set; }

        /// <summary>
        /// Tổng tiền TQ - VN
        /// </summary>
        public decimal? MaxFeeWeight { get; set; }

        /// <summary>
        /// Tổng tiền mua hàng
        /// </summary>
        public decimal? MaxFeeBuyPro { get; set; }

        /// <summary>
        /// Tổng tiền kiểm đếm
        /// </summary>
        public decimal? MaxIsCheckProductPrice { get; set; }

        /// <summary>
        /// Tổng tiền đóng gỗ
        /// </summary>
        public decimal? MaxIsPackedPrice { get; set; }

        /// <summary>
        /// Tổng tiền bảo hiểm
        /// </summary>
        public decimal? MaxInsuranceMoney { get; set; }

        /// <summary>
        /// Tổng tiền lưu kho
        /// </summary>
        public decimal? MaxFeeInWareHouse { get; set; }
    }
}
