using NhapHangV2.Entities.DomainEntities;
using System;
using System.Collections.Generic;
using System.Text;

namespace NhapHangV2.Entities.Search
{
    public class UserSearch : BaseSearch
    {
        /// <summary>
        /// Tìm kiếm theo Id (Mã khách hàng)
        /// </summary>
        public int? UID { get; set; }

        /// <summary>
        /// Tìm kiếm theo Id (Mã khách hàng)
        /// </summary>
        public int? RoleID { get; set; }

        /// <summary>
        /// Tìm kiếm theo UserName
        /// </summary>
        public string UserName { get; set; }

        /// <summary>
        /// Tìm kiếm theo số điện thoại
        /// </summary>
        public string Phone { get; set; }

        /// <summary>
        /// Theo quyền hạn (Trang Danh sách khách hàng => UserGroupId = 2)
        /// </summary>
        public int? UserGroupId { get; set; }

        /// <summary>
        /// Theo trạng thái
        /// </summary>
        public int? Status { get; set; }

        /// <summary>
        /// Tìm kiếm theo saler (thống kê)
        /// </summary>
        public int? SalerID { get; set; }

        /// <summary>
        /// Tìm kiếm theo người đặt hàng (thống kê)
        /// </summary>
        public int? OrdererID { get; set; }

        /// <summary>
        /// Tìm kiếm là nhân vi
        /// </summary>
        public int? IsEmployee { get; set; }
    }
}
