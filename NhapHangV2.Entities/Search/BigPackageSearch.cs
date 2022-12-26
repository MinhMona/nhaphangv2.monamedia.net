using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Search
{
    public class BigPackageSearch : BaseSearch
    {
        /// <summary>
        /// Active
        /// </summary>
        public bool? Active { set; get; }
        /// <summary>
        /// Trạng thái bao lớn 1 Đang về VN, 2 Đã nhận tại kho VN, 3 Hủy,
        /// </summary>
        public int? Status { get; set; }
    }
}
