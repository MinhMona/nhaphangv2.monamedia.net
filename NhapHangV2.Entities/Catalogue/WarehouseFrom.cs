using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Catalogue
{
    public class WarehouseFrom : AppDomainCatalogue
    {
        /// <summary>
        /// Vỹ độ
        /// </summary>
        [StringLength(50)]
        public string Latitude { get; set; } = string.Empty;

        /// <summary>
        /// Kinh độ
        /// </summary>
        [StringLength(50)]
        public string Longitude { get; set; } = string.Empty;

        /// <summary>
        /// Kho Trung Quốc
        /// </summary>
        public bool IsChina { get; set; } = true;

        /// <summary>
        /// Địa chỉ cụ thể
        /// </summary>
        public string Address { get; set; } = string.Empty;
    }
}
