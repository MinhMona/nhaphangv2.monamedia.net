using NhapHangV2.Request.DomainRequests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Request.Catalogue
{
    public class MenuRequest : AppDomainCatalogueRequest
    {
        /// <summary>
        /// Link menu
        /// </summary>
        public string? Link { get; set; }

        /// <summary>
        /// 1. Ngoài, 2. Trong
        /// </summary>
        public int? Type { get; set; }

        /// <summary>
        /// Id menu Cha
        /// </summary>
        public int? Parent { get; set; }

        /// <summary>
        /// Vị trí
        /// </summary>
        public int? Position { get; set; }
    }
}
