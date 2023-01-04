using NhapHangV2.Models.DomainModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Models.Catalogue
{
    public class WarehouseFromModel : AppDomainCatalogueModel
    {
        /// <summary>
        /// Vỹ độ
        /// </summary>
        public string Latitude { get; set; }

        /// <summary>
        /// Kinh độ
        /// </summary>
        public string Longitude { get; set; }

        /// <summary>
        /// Kho Trung Quốc
        /// </summary>
        public bool IsChina { get; set; }

        /// <summary>
        /// Địa chỉ cụ thể
        /// </summary>
        public string Address { get; set; }
    }
}
