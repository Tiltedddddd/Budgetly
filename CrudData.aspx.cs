using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Budgetly.Class;

namespace Budgetly
{
    public partial class CRUDData : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Ensure dropdown has a value before selecting
                if (ddlTable.Items.FindByValue("Users") != null)
                {
                    ddlTable.SelectedValue = "Users";
                    LoadTable();
                }
            }
        }

        protected void ddlTable_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlTable.SelectedValue))
                LoadTable();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlTable.SelectedValue))
                LoadTable();
        }

        private void LoadTable()
        {
            try
            {
                lblMessage.Text = "";
                lblError.Text = "";
                lblStats.Text = "";

                string table = ddlTable.SelectedValue;
                string pk = GetPrimaryKey(table);

                if (string.IsNullOrEmpty(pk))
                    throw new Exception("Primary key not defined.");

                gvData.EditIndex = -1;
                gvData.DataKeyNames = new[] { pk };

                DataTable dt = DbHelper.GetData(
                    $"SELECT * FROM [{table}] ORDER BY [{pk}]");

                gvData.DataSource = dt;
                gvData.DataBind();

                lblStats.Text = $"Table: {table} | Records: {dt.Rows.Count} | PK: {pk}";
            }
            catch (Exception ex)
            {
                lblError.Text = "Load error: " + ex.Message;
            }
        }

        protected void gv_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvData.EditIndex = e.NewEditIndex;
            LoadTable();
        }

        protected void gv_RowCancel(object sender, GridViewCancelEditEventArgs e)
        {
            gvData.EditIndex = -1;
            LoadTable();
        }

        protected void gv_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                string table = ddlTable.SelectedValue;
                string pk = GetPrimaryKey(table);

                object keyValue = gvData.DataKeys[e.RowIndex].Value;

                if (keyValue == null)
                    throw new Exception("Primary key value missing.");

                if (HasDependencies(table, pk, keyValue))
                {
                    lblError.Text = "Cannot delete. Record is referenced elsewhere.";
                    return;
                }

                DbHelper.Execute(
                    $"DELETE FROM [{table}] WHERE [{pk}] = @id",
                    new[] { new SqlParameter("@id", keyValue) });

                lblMessage.Text = $"Deleted from {table}";
                LoadTable();
            }
            catch (Exception ex)
            {
                lblError.Text = "Delete failed: " + ex.Message;
            }
        }

        protected void gv_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            // Intentionally disabled (generic updates are dangerous)
            gvData.EditIndex = -1;
            lblError.Text = "Generic UPDATE disabled. Create table-specific edit pages.";
            LoadTable();
        }

        protected void gvData_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvData.PageIndex = e.NewPageIndex;
            LoadTable();
        }

        private string GetPrimaryKey(string table)
        {
            switch (table)
            {
                case "Users": return "UserID";
                case "UserProfiles": return "ProfileID";
                case "Subscriptions": return "SubscriptionID";
                case "UserSubscriptions": return "UserSubscriptionID";
                case "Accounts": return "AccountID";
                case "AccountImages": return "ImageID";
                case "Categories": return "CategoryID";
                case "Transactions": return "TransactionID";
                case "TransactionAttachments": return "AttachmentID";
                case "GmailTransactionTracker": return "GmailID";
                case "Income": return "IncomeID";
                case "Budgets": return "BudgetID";
                case "BudgetEnvelopes": return "EnvelopeID";
                case "BudgetProgress": return "ProgressID";
                case "Pets": return "PetID";
                case "UserPets": return "UserPetID";
                case "PetStatusImages": return "StatusImageID";
                case "Badges": return "BadgeID";
                case "UserBadges": return "UserBadgeID";
                case "Challenges": return "ChallengeID";
                case "UserChallenges": return "UserChallengeID";
                case "LeaderboardStats": return "LeaderboardID";
                case "EcoScores": return "EcoScoreID";
                case "MerchantRules": return "RuleID";
                default: return null;
            }
        }

        private bool HasDependencies(string table, string pk, object id)
        {
            object count;

            switch (table)
            {
                case "Users":
                    count = DbHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM Accounts WHERE UserID = @id",
                        new[] { new SqlParameter("@id", id) });
                    return Convert.ToInt32(count) > 0;

                case "Categories":
                    count = DbHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM Transactions WHERE CategoryID = @id",
                        new[] { new SqlParameter("@id", id) });
                    return Convert.ToInt32(count) > 0;

                default:
                    return false;
            }
        }
    }
}
