using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Search
{
    public class PayHelpSearch : BaseSearch
    {
        public int? UID { get; set; }

        /// <summary>
        /// UserGroupID
        /// </summary>
        public int? RoleID { get; set; }

        public int? Status { get; set; }

        public DateTime? FromDate { get; set; }

        public DateTime? ToDate { get; set; }

        public int? SalerId { get; set; }

        public int? DatHangId { get; set; }
    }
}
