using Budgetly.Class;
using System;


    namespace Budgetly
    {
        public partial class ViewData : System.Web.UI.Page
        {
            protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid(gvUsers, "Users");
                BindGrid(gvUserProfiles, "UserProfiles");
                BindGrid(gvSubscriptions, "Subscriptions");
                BindGrid(gvUserSubscriptions, "UserSubscriptions");
                BindGrid(gvAccounts, "Accounts");
                BindGrid(gvAccountImages, "AccountImages");
                BindGrid(gvCategories, "Categories");
                BindGrid(gvTransactions, "Transactions");
                BindGrid(gvTransactionAttachments, "TransactionAttachments");
                BindGrid(gvGmailTransactionTracker, "GmailTransactionTracker");
                BindGrid(gvIncome, "Income");
                BindGrid(gvBudgets, "Budgets");
                BindGrid(gvBudgetEnvelopes, "BudgetEnvelopes");
                BindGrid(gvBudgetProgress, "BudgetProgress");
                BindGrid(gvPets, "Pets");
                BindGrid(gvUserPets, "UserPets");
                BindGrid(gvPetStatusImages, "PetStatusImages");
                BindGrid(gvBadges, "Badges");
                BindGrid(gvUserBadges, "UserBadges");
                BindGrid(gvChallenges, "Challenges");
                BindGrid(gvUserChallenges, "UserChallenges");
                BindGrid(gvLeaderboardStats, "LeaderboardStats");
                BindGrid(gvEcoScores, "EcoScores");
                BindGrid(gvMerchantRules, "MerchantRules");
            }
        }

        private void BindGrid(System.Web.UI.WebControls.GridView grid, string tableName)
        {
            grid.DataSource = DbHelper.GetData($"SELECT * FROM {tableName}");
            grid.DataBind();
        }
    }
}
