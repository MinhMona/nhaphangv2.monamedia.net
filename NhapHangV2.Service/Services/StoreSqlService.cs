using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using NhapHangV2.Entities.Search;
using NhapHangV2.Interface.DbContext;
using NhapHangV2.Interface.Services;
using NhapHangV2.Utilities;
using Polly;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NhapHangV2.Service.Services
{
    public class StoreSqlService<T> : IStoreSqlService<T>
    {
        protected readonly IAppDbContext Context;
        public StoreSqlService(IServiceProvider serviceProvider)
        {
            Context = serviceProvider.GetRequiredService<IAppDbContext>();
        }
        public List<T> GetDataFromStore(SqlParameter[] sqlParameter, string commnadText)
        {
            SqlConnection connection = null;
            SqlCommand command = null;
            DataTable dataTable = new DataTable();
            try
            {
                connection = (SqlConnection)Context.Database.GetDbConnection();
                command = connection.CreateCommand();
                connection.Open();
                command.CommandText = commnadText;
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddRange(sqlParameter);
                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(command);
                sqlDataAdapter.Fill(dataTable);
                var result = MappingDataTable.ConvertToList<T>(dataTable);

                return result;

            }
            finally
            {
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                    connection.Close();

                if (command != null)
                    command.Dispose();
            }
        }
        public DataTable GetDataTableFromStore(SqlParameter[] sqlParameter, string commnadText)
        {
            SqlConnection connection = null;
            SqlCommand command = null;
            DataTable dataTable = new DataTable();
            try
            {
                connection = (SqlConnection)Context.Database.GetDbConnection();
                command = connection.CreateCommand();
                connection.Open();
                command.CommandText = commnadText;
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddRange(sqlParameter);
                SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(command);
                sqlDataAdapter.Fill(dataTable);
                return dataTable;

            }
            finally
            {
                if (connection != null && connection.State == System.Data.ConnectionState.Open)
                    connection.Close();

                if (command != null)
                    command.Dispose();
            }
        }
    }
}
