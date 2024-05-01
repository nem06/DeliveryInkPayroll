using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class DBHelper(IConfiguration configuration)
    {
        private readonly IConfiguration _configuration = configuration;

        public int RunInsertStoreProcedure(string storeProcedure, string inputJSON)
        {
            string connectionString = _configuration["DBConnectionString"];
            int RowsAffected;
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand(storeProcedure, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        if(inputJSON != null)
                            command.Parameters.AddWithValue("@jsonData", inputJSON);
                        RowsAffected = command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }
            return RowsAffected;
        }

        public string RunGetStoreProcedure(string storeProcedure, string inputJSON)
        {
            string connectionString = _configuration["DBConnectionString"];
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand(storeProcedure, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        SqlParameter outputParameter = new SqlParameter("@jsonDataOut", SqlDbType.VarChar, -1);
                        outputParameter.Direction = ParameterDirection.Output;
                        if (inputJSON != null)
                            command.Parameters.AddWithValue("@jsonData", inputJSON);
                        command.Parameters.Add(outputParameter);
                        command.ExecuteNonQuery();
                        
                        return outputParameter.Value.ToString();
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
