using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Entities.Search.Report
{
    public class MainOrderReportSearch : BaseSearch
    {
        /// <summary>
        /// Tài khoản đang đăng nhập
        /// </summary>
        public int? UID { get; set; }

        /// <summary>
        /// UserGroupID
        /// </summary>
        public int? RoleID { get; set; }
        /// <summary>
        /// 5. Thống kê lợi nhuận mua hộ
        /// </summary>
        public int Status { get; set; }

        /// <summary>
        /// Từ ngày
        /// </summary>
        public DateTime? FromDate { get; set; }

        /// <summary>
        /// Đến ngày
        /// </summary>
        public DateTime? ToDate { get; set; }
    }
}
