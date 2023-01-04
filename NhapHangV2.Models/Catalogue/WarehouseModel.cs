using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Models.Catalogue
{
    public class WarehouseModel : AppDomainCatalogueModel
    {
        /// <summary>
        /// Vĩ độ
        /// </summary>
        public string Latitude { get; set; }

        /// <summary>
        /// Kinh độ
        /// </summary>
        public string Longitude { get; set; }

        /// <summary>
        /// Ngày dự kiến
        /// </summary>
        public int? ExpectedDate { get; set; }

        /// <summary>
        /// Kho Việt Nam
        /// </summary>
        public bool IsChina { get; set; }

        /// <summary>
        /// Địa chỉ cụ thể
        /// </summary>
        public string Address { get; set; }
    }
}
