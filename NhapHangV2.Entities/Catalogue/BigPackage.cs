using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Catalogue
{
    public class BigPackage : AppDomainCatalogue
    {
        /// <summary>
        /// Cân nặng (kg)
        /// </summary>
        [Column(TypeName = "decimal(18,1)")]
        public decimal? Weight { get; set; } = 0;

        /// <summary>
        /// Khối (m3)
        /// </summary>
        [Column(TypeName = "decimal(18,0)")]
        public decimal? Volume { get; set; } = 0;

        /// <summary>
        /// Trạng thái
        /// </summary>
        public int? Status { get; set; } = 1; //Bao hàng ở TQ

        /// <summary>
        /// Tổng kiện
        /// </summary>
        [NotMapped]
        public int? Total { get; set; } = 0;

        [NotMapped]
        public List<SmallPackage> SmallPackages { get; set; } = new List<SmallPackage>();
    }
}
