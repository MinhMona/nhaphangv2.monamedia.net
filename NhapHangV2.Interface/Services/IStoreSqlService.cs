using Microsoft.Data.SqlClient;
using NPOI.SS.Formula.Functions;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Interface.Services
{
    public interface IStoreSqlService<T>
    {
        List<T> GetDataFromStore(SqlParameter[] sqlParameter, string commnadText);
        DataTable GetDataTableFromStore(SqlParameter[] sqlParameter, string commnadText);
    }
}
