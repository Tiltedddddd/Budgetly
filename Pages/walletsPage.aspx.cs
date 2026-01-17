using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Budgetly.Pages
{
    public partial class walletsPage : System.Web.UI.Page
    {
        // Single source of truth for the connection string
        private string ConnStr
        {
            get
            {
                var cs = ConfigurationManager.ConnectionStrings["BudgetlyDBContext"];
                if (cs == null || string.IsNullOrWhiteSpace(cs.ConnectionString))
                    throw new Exception("web.config missing connection string 'BudgetlyDBContext' under <connectionStrings>.");

                return cs.ConnectionString;
            }
        }

        private int CurrentUserId
        {
            get
            {
                if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid))
                    return uid;

                return 1; // dev fallback
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindWallets();
        }

        private void BindWallets()
        {
            lblError.Visible = false;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"
                    SELECT
                        a.AccountID,
                        a.AccountName,
                        a.AccountType,
                        a.Balance,
                        a.IsGmailSyncEnabled,
                        a.IsDefault
                    FROM Accounts a
                    WHERE a.UserID = @UserID
                    ORDER BY a.IsDefault DESC, a.AccountName ASC;
                ", con))
                {
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    // UI-only computed columns
                    dt.Columns.Add("IsCash", typeof(bool));
                    dt.Columns.Add("BadgeText", typeof(string));
                    dt.Columns.Add("BadgeCss", typeof(string));

                    foreach (DataRow row in dt.Rows)
                    {
                        string name = (row["AccountName"] ?? "").ToString();
                        string type = (row["AccountType"] ?? "").ToString();
                        bool isDefault = Convert.ToBoolean(row["IsDefault"]);

                        bool isCash = type.Equals("Cash", StringComparison.OrdinalIgnoreCase);
                        row["IsCash"] = isCash;

                        string badgeText = GetBadgeText(name, type);
                        string badgeCss = GetBadgeCss(badgeText, type, isDefault);

                        row["BadgeText"] = badgeText;
                        row["BadgeCss"] = badgeCss;
                    }

                    rptWallets.DataSource = dt;
                    rptWallets.DataBind();
                }
            }
            catch (SqlException ex)
            {
                // Most common: wrong DB (table missing) or cannot connect
                lblError.Text = "Database error: " + ex.Message;
                lblError.Visible = true;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error: " + ex.Message;
                lblError.Visible = true;
            }
        }

        private string GetBadgeText(string accountName, string accountType)
        {
            if (accountType.Equals("Cash", StringComparison.OrdinalIgnoreCase))
                return "$";

            if (string.IsNullOrWhiteSpace(accountName))
                return accountType.Length >= 3 ? accountType.Substring(0, 3).ToUpperInvariant() : accountType.ToUpperInvariant();

            string first = accountName.Trim().Split(' ')[0].Trim();
            if (first.Length > 6) first = first.Substring(0, 6);
            return first.ToUpperInvariant();
        }

        private string GetBadgeCss(string badgeText, string accountType, bool isDefault)
        {
            if (accountType.Equals("Cash", StringComparison.OrdinalIgnoreCase))
                return "badge-cash";

            switch (badgeText)
            {
                case "TRUST": return "badge-trust";
                case "DBS": return "badge-dbs";
                case "OCBC": return "badge-ocbc";
                default:
                    return "badge-default";
            }
        }

        protected void rptWallets_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            lblError.Visible = false;

            if (!int.TryParse(e.CommandArgument?.ToString(), out int accountId))
                return;

            try
            {
                switch (e.CommandName)
                {
                    case "Edit":
                        OpenEditModal(accountId);
                        break;

                    case "Remove":
                        RemoveAccount(accountId);
                        BindWallets();
                        break;

                    case "Default":
                        SetDefaultAccount(accountId);
                        BindWallets();
                        break;
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Something went wrong: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void btnShowAdd_Click(object sender, EventArgs e)
        {
            hfEditingAccountID.Value = "";
            lblModalTitle.Text = "Add Card";
            lblModalError.Visible = false;

            txtAccountName.Text = "";
            txtBalance.Text = "";
            ddlAccountType.SelectedValue = "Savings";
            chkGmailSync.Checked = false;

            pnlModal.Visible = true;
        }

        private void OpenEditModal(int accountId)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(@"
                SELECT AccountID, AccountName, AccountType, Balance, IsGmailSyncEnabled
                FROM Accounts
                WHERE AccountID = @AccountID AND UserID = @UserID;
            ", con))
            {
                cmd.Parameters.Add("@AccountID", SqlDbType.Int).Value = accountId;
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                        throw new Exception("Wallet not found.");

                    hfEditingAccountID.Value = r["AccountID"].ToString();
                    txtAccountName.Text = r["AccountName"].ToString();
                    txtBalance.Text = Convert.ToDecimal(r["Balance"]).ToString("0.00");

                    string type = r["AccountType"].ToString();
                    if (ddlAccountType.Items.FindByValue(type) != null)
                        ddlAccountType.SelectedValue = type;

                    chkGmailSync.Checked = Convert.ToBoolean(r["IsGmailSyncEnabled"]);
                }
            }

            lblModalTitle.Text = "Edit Card";
            lblModalError.Visible = false;
            pnlModal.Visible = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
            lblModalError.Visible = false;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblModalError.Visible = false;

            string name = (txtAccountName.Text ?? "").Trim();
            string type = ddlAccountType.SelectedValue;
            bool gmail = chkGmailSync.Checked;

            if (string.IsNullOrWhiteSpace(name))
            {
                lblModalError.Text = "Account name is required.";
                lblModalError.Visible = true;
                pnlModal.Visible = true;
                return;
            }

            if (!decimal.TryParse(txtBalance.Text?.Trim(), out decimal balance))
            {
                lblModalError.Text = "Balance must be a valid number.";
                lblModalError.Visible = true;
                pnlModal.Visible = true;
                return;
            }

            // Cash is manual
            if (type.Equals("Cash", StringComparison.OrdinalIgnoreCase))
                gmail = false;

            if (int.TryParse(hfEditingAccountID.Value, out int editingId))
                UpdateAccount(editingId, name, type, balance, gmail);
            else
                AddAccount(name, type, balance, gmail);

            pnlModal.Visible = false;
            BindWallets();
        }

        private void AddAccount(string name, string type, decimal balance, bool gmail)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(@"
                INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
                VALUES (@UserID, @Name, @Type, @Balance, @Gmail, 0);
            ", con))
            {
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;
                cmd.Parameters.Add("@Name", SqlDbType.VarChar, 50).Value = name;
                cmd.Parameters.Add("@Type", SqlDbType.VarChar, 20).Value = type;
                cmd.Parameters.Add("@Balance", SqlDbType.Decimal).Value = balance;
                cmd.Parameters.Add("@Gmail", SqlDbType.Bit).Value = gmail;

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateAccount(int accountId, string name, string type, decimal balance, bool gmail)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(@"
                UPDATE Accounts
                SET AccountName = @Name,
                    AccountType = @Type,
                    Balance = @Balance,
                    IsGmailSyncEnabled = @Gmail
                WHERE AccountID = @AccountID AND UserID = @UserID;
            ", con))
            {
                cmd.Parameters.Add("@Name", SqlDbType.VarChar, 50).Value = name;
                cmd.Parameters.Add("@Type", SqlDbType.VarChar, 20).Value = type;
                cmd.Parameters.Add("@Balance", SqlDbType.Decimal).Value = balance;
                cmd.Parameters.Add("@Gmail", SqlDbType.Bit).Value = gmail;
                cmd.Parameters.Add("@AccountID", SqlDbType.Int).Value = accountId;
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                con.Open();
                int rows = cmd.ExecuteNonQuery();
                if (rows == 0) throw new Exception("Update failed (wallet not found).");
            }
        }

        private void RemoveAccount(int accountId)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(@"
                DELETE FROM Accounts
                WHERE AccountID = @AccountID AND UserID = @UserID;
            ", con))
            {
                cmd.Parameters.Add("@AccountID", SqlDbType.Int).Value = accountId;
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void SetDefaultAccount(int accountId)
        {
            using (var con = new SqlConnection(ConnStr))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    using (var cmd1 = new SqlCommand(@"
                        UPDATE Accounts
                        SET IsDefault = 0
                        WHERE UserID = @UserID;
                    ", con, tx))
                    {
                        cmd1.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;
                        cmd1.ExecuteNonQuery();
                    }

                    using (var cmd2 = new SqlCommand(@"
                        UPDATE Accounts
                        SET IsDefault = 1
                        WHERE AccountID = @AccountID AND UserID = @UserID;
                    ", con, tx))
                    {
                        cmd2.Parameters.Add("@AccountID", SqlDbType.Int).Value = accountId;
                        cmd2.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                        int rows = cmd2.ExecuteNonQuery();
                        if (rows == 0)
                            throw new Exception("Default set failed (wallet not found).");
                    }

                    tx.Commit();
                }
            }
        }
    }
}
