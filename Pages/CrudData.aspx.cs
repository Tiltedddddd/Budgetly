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

        private void ClearCategoryForm()
        {
            hfCategoryID.Value = "";
            txtCategoryName.Text = "";
            txtEcoWeight.Text = "";
            chkIsEssential.Checked = false;
            txtIconPath.Text = "";
        }


        private void LoadTable()
        {
            try
            {
                lblMessage.Text = "";
                lblError.Text = "";
                lblStats.Text = "";

                string table = ddlTable.SelectedValue;
                pnlCategories.Visible = table.Equals("Categories", StringComparison.OrdinalIgnoreCase);
                if (!pnlCategories.Visible)
                {
                    ClearCategoryForm();
                }


                if (!IsAllowedTable(table))
                    throw new Exception("Invalid table selection.");

                string pk = GetPrimaryKey(table);


                if (string.IsNullOrEmpty(pk))
                    throw new Exception("Primary key not defined.");

                gvData.EditIndex = -1;
                gvData.DataKeyNames = new[] { pk };

                DataTable dt = DbHelper.GetData(
                    $"SELECT TOP 200 * FROM [{table}] ORDER BY [{pk}] DESC");


                gvData.DataSource = dt;
                gvData.DataBind();

                lblStats.Text = $"Table: {table} | Records: {dt.Rows.Count} | PK: {pk}";
            }
            catch (Exception ex)
            {
                lblError.Text = "Load error: " + Server.HtmlEncode(ex.Message);
            }
        }

        protected void btnUpdateCategory_Click(object sender, EventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                lblError.Text = "";

                if (string.IsNullOrWhiteSpace(hfCategoryID.Value))
                    throw new Exception("Select a category row first.");

                int id = int.Parse(hfCategoryID.Value);

                string name = txtCategoryName.Text.Trim();
                string icon = txtIconPath.Text.Trim();

                if (string.IsNullOrWhiteSpace(name))
                    throw new Exception("Category Name is required.");

                if (!decimal.TryParse(txtEcoWeight.Text.Trim(), out decimal eco))
                    throw new Exception("Eco Weight must be a number (e.g., 0.75).");

                if (eco < 0 || eco > 1)
                    throw new Exception("Eco Weight must be between 0 and 1.");

                DbHelper.Execute(
                    "UPDATE Categories SET CategoryName=@name, EcoWeight=@eco, IsEssential=@ess, IconPath=@icon WHERE CategoryID=@id",
                    new[]
                    {
                new SqlParameter("@name", name),
                new SqlParameter("@eco", eco),
                new SqlParameter("@ess", chkIsEssential.Checked),
                new SqlParameter("@icon", string.IsNullOrWhiteSpace(icon) ? (object)DBNull.Value : icon),
                new SqlParameter("@id", id)
                    }
                );

                lblMessage.Text = "Category updated.";
                ClearCategoryForm();
                LoadTable();
            }
            catch (Exception ex)
            {
                lblError.Text = "Update failed: " + Server.HtmlEncode(ex.Message);

            }
        }

        protected void btnClearCategory_Click(object sender, EventArgs e)
        {
            ClearCategoryForm();
            lblMessage.Text = "Cleared.";
            lblError.Text = "";
        }


        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                lblError.Text = "";

                string name = txtCategoryName.Text.Trim();
                string icon = txtIconPath.Text.Trim();

                if (string.IsNullOrWhiteSpace(name))
                    throw new Exception("Category Name is required.");

                if (!decimal.TryParse(txtEcoWeight.Text.Trim(), out decimal eco))
                    throw new Exception("Eco Weight must be a number (e.g., 0.75).");

                if (eco < 0 || eco > 1)
                    throw new Exception("Eco Weight must be between 0 and 1.");

                DbHelper.Execute(
                    "INSERT INTO Categories (CategoryName, EcoWeight, IsEssential, IconPath) VALUES (@name, @eco, @ess, @icon)",
                    new[]
                    {
                new SqlParameter("@name", name),
                new SqlParameter("@eco", eco),
                new SqlParameter("@ess", chkIsEssential.Checked),
                new SqlParameter("@icon", string.IsNullOrWhiteSpace(icon) ? (object)DBNull.Value : icon)
                    }
                );

                lblMessage.Text = "Category added.";
                ClearCategoryForm();
                LoadTable();
            }
            catch (Exception ex)
            {
                lblError.Text = "Add failed: " + Server.HtmlEncode(ex.Message);

            }
        }


        protected void gv_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                lblError.Text = "";

                string table = ddlTable.SelectedValue;

                if (!IsAllowedTable(table))
                    throw new Exception("Invalid table selection.");

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
                    new[] { new SqlParameter("@id", keyValue) }
                );

                lblMessage.Text = $"Deleted from {Server.HtmlEncode(table)} (ID={Server.HtmlEncode(keyValue.ToString())})";
                LoadTable();
            }
            catch (Exception ex)
            {
                lblError.Text = "Delete failed: " + Server.HtmlEncode(ex.Message);
            }
        }


        protected void gvData_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvData.PageIndex = e.NewPageIndex;
            LoadTable();
        }

        protected void gvData_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!ddlTable.SelectedValue.Equals("Categories", StringComparison.OrdinalIgnoreCase))
                return;

            // We expect CategoryID to exist in the grid data
            GridViewRow row = gvData.SelectedRow;
            if (row == null) return;

            // AutoGenerateColumns means cells are positional:
            // Cell[0] = Select button, then columns start.
            // We'll read from DataKeys instead (safer).
            // So ensure DataKeyNames is set to CategoryID in GetPrimaryKey() (you already have it).

            object idObj = gvData.SelectedDataKey?.Value;
            if (idObj == null) return;

            hfCategoryID.Value = idObj.ToString();

            // Pull latest from DB by ID (most reliable)
            DataTable dt = DbHelper.GetData(
                "SELECT CategoryName, EcoWeight, IsEssential, IconPath FROM Categories WHERE CategoryID=@id",
                new[] { new SqlParameter("@id", idObj) }
            );

            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            txtCategoryName.Text = r["CategoryName"].ToString();
            txtEcoWeight.Text = r["EcoWeight"].ToString();
            chkIsEssential.Checked = Convert.ToBoolean(r["IsEssential"]);
            txtIconPath.Text = r["IconPath"] == DBNull.Value ? "" : r["IconPath"].ToString();

            lblMessage.Text = "Loaded category for update.";
            lblError.Text = "";
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

        private bool IsAllowedTable(string table)
        {
            switch (table)
            {
                case "Users":
                case "UserProfiles":
                case "Subscriptions":
                case "UserSubscriptions":
                case "Accounts":
                case "AccountImages":
                case "Categories":
                case "Transactions":
                case "TransactionAttachments":
                case "GmailTransactionTracker":
                case "Income":
                case "Budgets":
                case "BudgetEnvelopes":
                case "BudgetProgress":
                case "Pets":
                case "UserPets":
                case "PetStatusImages":
                case "Badges":
                case "UserBadges":
                case "Challenges":
                case "UserChallenges":
                case "LeaderboardStats":
                case "EcoScores":
                case "MerchantRules":
                    return true;
                default:
                    return false;
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
