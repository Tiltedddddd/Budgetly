using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Budgetly.Class
{
    public static class DbHelper
    {
        private static readonly string connStr =
            ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        /* (I used this to debug my localdb issues, this may help yall if u run into the same issue as me, just remember to update the debug statement in viewdata)
        public static string DebugConnStr() => connStr;

        public static string DebugEnvironment()
        {
            return
                $"Is64BitProcess: {Environment.Is64BitProcess}\n" +
                $"Is64BitOS: {Environment.Is64BitOperatingSystem}\n" +
                $"Process: {System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName}\n" +
                $"ConnStr: {connStr}\n";
        }
        */

        public static bool CanConnect(out string error)
        {
            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                }
                error = null;
                return true;
            }
            catch (Exception ex)
            {
                error = ex.ToString(); 
                return false;
            }
        }



        public static DataTable GetData(string query)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 10;

                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        public static DataTable GetData(string query, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 10;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        public static int Execute(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 10;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 10;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                return cmd.ExecuteScalar();
            }
        }
    }
}
