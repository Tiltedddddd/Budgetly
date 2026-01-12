using Budgetly.Class;
using Budgetly.Models.DTOs;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Http;

namespace Budgetly.Controllers
{
    public class DashboardApiController : ApiController
    {
        private readonly string _conn =
            ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        [HttpGet]
        [Route("api/accounts")]
        public IHttpActionResult GetAccounts()
        {
            try
            {
                int userId = 1; // TEMP until i make auth 

                var result = new List<DashboardAccountDto>();


                using (var conn = new SqlConnection(_conn))
                using (var cmd = new SqlCommand(@"
            SELECT AccountID, AccountName, AccountType, Balance, IsDefault
            FROM Accounts
            WHERE UserID = @UserID
            ORDER BY IsDefault DESC, AccountID", conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    conn.Open();

                    var rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        result.Add(new DashboardAccountDto
                        {
                            AccountId = Convert.ToInt32(rdr["AccountID"]),
                            Name = rdr["AccountName"].ToString(),
                            Type = rdr["AccountType"].ToString(),
                            Balance = Convert.ToDecimal(rdr["Balance"]),
                            IsDefault = Convert.ToBoolean(rdr["IsDefault"])
                        });
                    }
                }

                return Ok(result);
            }

            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }

        [HttpGet]
        [Route("api/transactions")]
        public IHttpActionResult GetTransactions(int accountId)
        {
            if (accountId <= 0)
                return BadRequest("Invalid account ID.");

            try
            {
                var result = new List<DashboardTransactionDto>();

                using (var conn = new SqlConnection(_conn))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10
                        t.Amount,
                        t.TransactionType,
                        t.TransactionDate,
                        t.Merchant,
                        c.CategoryName,
                        c.IconPath
                    FROM Transactions t
                    JOIN Categories c ON t.CategoryID = c.CategoryID
                    WHERE t.AccountID = @AccountID
                    ORDER BY t.TransactionDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@AccountID", accountId);
                    conn.Open();

                    var rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        decimal amount = (decimal)rdr["Amount"];
                        bool isIncome = rdr["TransactionType"].ToString() == "INCOME";

                        result.Add(new DashboardTransactionDto
                        {
                            merchant = rdr["Merchant"].ToString(),
                            category = rdr["CategoryName"].ToString(),
                            amount = isIncome ? amount : -amount,
                            icon = rdr["IconPath"].ToString(),
                            date = (DateTime)rdr["TransactionDate"],
                            type = isIncome ? "INCOME" : "EXPENSE"
                        });
                    }
                }

                return Ok(result);
            }

            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }

        [HttpGet]
        [Route("api/expenses/summary")]
        public IHttpActionResult GetExpenseSummary(int accountId)
        {
            if (accountId <= 0)
                return BadRequest("Invalid account ID.");

            try
            {
                var result = new List<DashboardChartSummaryDto>();


                using (var conn = new SqlConnection(_conn))
                using (var cmd = new SqlCommand(@"
                    SELECT c.CategoryName, SUM(t.Amount) AS Total
                    FROM Transactions t
                    JOIN Categories c ON t.CategoryID = c.CategoryID
                    WHERE t.AccountID = @AccountID
                      AND t.TransactionType = 'EXPENSE'
                    GROUP BY c.CategoryName", conn))
                {
                    cmd.Parameters.AddWithValue("@AccountID", accountId);
                    conn.Open();

                    var rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        result.Add(new DashboardChartSummaryDto
                        {
                            label = rdr["CategoryName"].ToString(),
                            value = Convert.ToDecimal(rdr["Total"])
                        });
                    }
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }


        [HttpGet]
        [Route("api/income/summary")]
        public IHttpActionResult GetIncomeSummary(int accountId)
        {
            if (accountId <= 0)
                return BadRequest("Invalid account ID.");

            try
            {
                var result = new List<DashboardChartSummaryDto>();


                using (var conn = new SqlConnection(_conn))
                using (var cmd = new SqlCommand(@"
                    SELECT Source, SUM(Amount) AS Total
                    FROM Income
                    WHERE (AccountID = @AccountID OR AccountID IS NULL)
                    GROUP BY Source", conn))
                {
                    cmd.Parameters.AddWithValue("@AccountID", accountId);
                    conn.Open();

                    var rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        result.Add(new DashboardChartSummaryDto
                        {
                            label = rdr["Source"].ToString(),
                            value = Convert.ToDecimal(rdr["Total"])
                        });

                    }
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }

    }
}

