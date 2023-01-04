using NhapHangV2.Request.DomainRequests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Request.Catalogue
{
    public class WarehouseFromRequest : AppDomainCatalogueRequest
    {
        public string? Latitude { get; set; }
        public string? Longitude { get; set; }
        public bool IsChina { get; set; } = true;
        public string? Address { get; set; }
    }
}
