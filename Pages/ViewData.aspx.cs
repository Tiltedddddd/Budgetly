using Budgetly.Class;
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;


    namespace Budgetly
    {
        public partial class ViewData : System.Web.UI.Page
        {
        private static readonly HashSet<string> AllowedTables =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "Users","UserProfiles","Subscriptions","UserSubscriptions","Accounts","AccountImages","Categories",
            "Transactions","TransactionAttachments","GmailTransactionTracker","Income","Budgets","BudgetEnvelopes",
            "BudgetProgress","Pets","UserPets","PetStatusImages","Badges","UserBadges","Challenges","UserChallenges",
            "LeaderboardStats","EcoScores","MerchantRules"
        };

        private void SafeBind(GridView grid, string tableName)
        {
            try { BindGrid(grid, tableName); }
            catch (Exception ex)
            {
                Response.Write($"<pre>{Server.HtmlEncode(tableName)} failed: {Server.HtmlEncode(ex.Message)}</pre>");
            }
        }


        protected void Page_Load(object sender, EventArgs e)
        {

            /* (Debug for localdb issues)
            Response.Write("<pre>");
            Response.Write("Is64BitProcess: " + Environment.Is64BitProcess + "\n");
            Response.Write("Is64BitOS     : " + Environment.Is64BitOperatingSystem + "\n");
            Response.Write("Process       : " + System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName + "\n");
            Response.Write("</pre>");

            Response.Write("<pre>" + Server.HtmlEncode(DbHelper.DebugConnStr()) + "</pre>");

            Response.Write("<pre>" + Server.HtmlEncode(DbHelper.DebugEnvironment()) + "</pre>");

            */

            if (!DbHelper.CanConnect(out string err))
            {
                Response.Write("<h2>DB connection failed:</h2><pre>" + Server.HtmlEncode(err) + "</pre>");
                return;
            }

            if (!IsPostBack)
            {
                SafeBind(gvUsers, "Users");
                SafeBind(gvUserProfiles, "UserProfiles");
                SafeBind(gvSubscriptions, "Subscriptions");
                SafeBind(gvUserSubscriptions, "UserSubscriptions");
                SafeBind(gvAccounts, "Accounts");
                SafeBind(gvAccountImages, "AccountImages");
                SafeBind(gvCategories, "Categories");
                SafeBind(gvTransactions, "Transactions");
                SafeBind(gvTransactionAttachments, "TransactionAttachments");
                SafeBind(gvGmailTransactionTracker, "GmailTransactionTracker");
                SafeBind(gvIncome, "Income");
                SafeBind(gvBudgets, "Budgets");
                SafeBind(gvBudgetEnvelopes, "BudgetEnvelopes");
                SafeBind(gvBudgetProgress, "BudgetProgress");
                SafeBind(gvPets, "Pets");
                SafeBind(gvUserPets, "UserPets");
                SafeBind(gvPetStatusImages, "PetStatusImages");
                SafeBind(gvBadges, "Badges");
                SafeBind(gvUserBadges, "UserBadges");
                SafeBind(gvChallenges, "Challenges");
                SafeBind(gvUserChallenges, "UserChallenges");
                SafeBind(gvLeaderboardStats, "LeaderboardStats");
                SafeBind(gvEcoScores, "EcoScores");
                SafeBind(gvMerchantRules, "MerchantRules");
            }
        }

        private void BindGrid(GridView grid, string tableName)
        {

            // 1) basic whitelist (prevents mistakes later)
            if (!AllowedTables.Contains(tableName))
                throw new InvalidOperationException("Invalid table: " + tableName);

            // 2) Limit rows so the page doesn't become huge
            string sql = $"SELECT TOP 50 * FROM [{tableName}] ORDER BY 1 DESC";

            // 3) Optional: special-case tables with better ordering
            if (tableName.Equals("Transactions", StringComparison.OrdinalIgnoreCase))
                sql = "SELECT TOP 50 * FROM [Transactions] ORDER BY TransactionDate DESC";

            grid.DataSource = DbHelper.GetData(sql);
            grid.DataBind();
           
        }


    }
}
