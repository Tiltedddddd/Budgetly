using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Http;
using Budgetly.Models.DTOs; // Resolves CS0246

namespace Budgetly.Controllers
{
    [RoutePrefix("api/goals")]
    public class GoalsApiController : ApiController
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        [HttpGet]
        [Route("{yearMonth}")]
        public IHttpActionResult GetGoalDetails(string yearMonth)
        {
            // 1. Validation: Ensure the yearMonth format is correct (yyyy-MM)
            if (string.IsNullOrEmpty(yearMonth) || yearMonth.Length != 7)
            {
                return BadRequest("Invalid format. Use YYYY-MM.");
            }

            int userId = 1; // Temporary: Replace with Session/Auth later
            var summary = new GoalSummaryDto
            {
                YearMonth = yearMonth,
                Envelopes = new List<GoalEnvelopeDto>()
            };

            try
            {
                using (var conn = new SqlConnection(_conn))
                {
                    conn.Open();

                    // 2. Fetch Header (Income and Total Budget)
                    string sqlHeader = @"
                        SELECT 
                            (SELECT SUM(Amount) FROM Income WHERE UserID = @UID AND YearMonth = @YM) as TotalIncome,
                            (SELECT TotalAmount FROM Budgets WHERE UserID = @UID AND YearMonth = @YM) as BudgetLimit";

                    using (var cmd = new SqlCommand(sqlHeader, conn))
                    {
                        cmd.Parameters.AddWithValue("@UID", userId);
                        cmd.Parameters.AddWithValue("@YM", yearMonth);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                summary.MonthlyIncome = rdr["TotalIncome"] != DBNull.Value ? Convert.ToDecimal(rdr["TotalIncome"]) : 0;
                                summary.TotalBudgetLimit = rdr["BudgetLimit"] != DBNull.Value ? Convert.ToDecimal(rdr["BudgetLimit"]) : 0;
                            }
                        }
                    }

                    // 3. Fetch Detail Rows (Envelopes)
                    string sqlDetails = @"
                        SELECT 
                            e.EnvelopeID, c.CategoryName, e.MonthlyLimit, 
                            ISNULL(p.SpentAmount, 0) as Spent, 
                            ISNULL(p.RemainingAmount, e.MonthlyLimit) as Remaining
                        FROM BudgetEnvelopes e
                        JOIN Categories c ON e.CategoryID = c.CategoryID
                        JOIN Budgets b ON e.BudgetID = b.BudgetID
                        LEFT JOIN BudgetProgress p ON b.BudgetID = p.BudgetID AND e.CategoryID = p.CategoryID
                        WHERE b.UserID = @UID AND b.YearMonth = @YM";

                    using (var cmd = new SqlCommand(sqlDetails, conn))
                    {
                        cmd.Parameters.AddWithValue("@UID", userId);
                        cmd.Parameters.AddWithValue("@YM", yearMonth);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                summary.Envelopes.Add(new GoalEnvelopeDto
                                {
                                    EnvelopeId = Convert.ToInt32(rdr["EnvelopeID"]),
                                    CategoryName = rdr["CategoryName"].ToString(),
                                    MonthlyLimit = Convert.ToDecimal(rdr["MonthlyLimit"]),
                                    SpentAmount = Convert.ToDecimal(rdr["Spent"]),
                                    RemainingAmount = Convert.ToDecimal(rdr["Remaining"])
                                });
                            }
                        }
                    }
                }

                return Ok(summary);
            }
            catch (Exception ex)
            {
                // Log the exception here if you have a logger
                return InternalServerError(ex);
            }
        }
    }
}