using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Search
{
    public class NoticationSearch : BaseSearch
    {
        /// <summary>
        /// Từ ngày
        /// </summary>
        public DateTime? FromDate { get; set; }

        /// <summary>
        /// Đến ngày
        /// </summary>
        public DateTime? ToDate { get; set; }

        public int UID { get; set; }

        public int UserGroupId { get; set; }

        /// <summary>
        /// Loại thông báo: 0-Yêu cầu nạp,1-Yêu cầu rút, 2-Đơn hàng, 3-Khiếu nại, 4-Tất cả
        /// </summary>
        public int Type { get; set; } = 4;

        /// <summary>
        /// Là thông báo của nhân viên
        /// </summary>
        public bool? OfEmployee { get; set; }

        /// <summary>
        /// Đã đọc : 0-Tất cả, 1-Đã đọc, 2-Chưa đọc
        /// </summary>
        public int? IsRead { get; set; }
    }
}
