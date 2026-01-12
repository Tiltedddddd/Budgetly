using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Budgetly.Pages
{
    public partial class goalSettingPage : System.Web.UI.Page
    {
        private readonly string connStringName = "BudgetlyDBContext";
        private int CurrentUserID => Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

        private string SelectedMonth
        {
            get => ViewState["SelectedMonth"]?.ToString() ?? DateTime.Now.ToString("yyyy-MM");
            set => ViewState["SelectedMonth"] = value;
        }

        protected int EditingID
        {
            get => (int)(ViewState["EditingID"] ?? -1);
            set => ViewState["EditingID"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                string eventTarget = Request["__EVENTTARGET"];
                string eventArgument = Request["__EVENTARGUMENT"];
                if (eventTarget == "ReplaceCategory")
                {
                    ReplaceExistingCategory(int.Parse(eventArgument), decimal.Parse(txtAmount.Text));
                }
            }

            if (!IsPostBack)
            {
                LoadGoalData();
                PopulateCategoryDropdown();
            }
        }

        private void LoadGoalData()
        {
            string connStr = ConfigurationManager.ConnectionStrings[connStringName].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Fetch Income and Monthly Budget Total
                SqlCommand cmdData = new SqlCommand(@"
                    SELECT 
                        (SELECT SUM(Amount) FROM Income WHERE UserID=@UID AND YearMonth=@YM) as FixedIncome,
                        (SELECT TotalAmount FROM Budgets WHERE UserID=@UID AND YearMonth=@YM) as BudgetLimit", conn);

                cmdData.Parameters.AddWithValue("@UID", CurrentUserID);
                cmdData.Parameters.AddWithValue("@YM", SelectedMonth);

                decimal fixedIncome = 0;
                decimal monthlyBudgetLimit = 0;

                using (SqlDataReader reader = cmdData.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        fixedIncome = reader["FixedIncome"] != DBNull.Value ? Convert.ToDecimal(reader["FixedIncome"]) : 0;
                        monthlyBudgetLimit = reader["BudgetLimit"] != DBNull.Value ? Convert.ToDecimal(reader["BudgetLimit"]) : 0;
                    }
                }

                litIncomeSub.Text = fixedIncome.ToString("N2");
                litBudgetAmount.Text = monthlyBudgetLimit.ToString("N2");

                // 2. Fetch Envelopes JOINED with Progress
                string sql = @"
                    SELECT 
                        e.EnvelopeID, 
                        c.CategoryName, 
                        e.MonthlyLimit,
                        ISNULL(p.SpentAmount, 0) as SpentAmount,
                        ISNULL(p.RemainingAmount, e.MonthlyLimit) as RemainingAmount
                    FROM BudgetEnvelopes e 
                    JOIN Categories c ON e.CategoryID = c.CategoryID
                    JOIN Budgets b ON e.BudgetID = b.BudgetID 
                    LEFT JOIN BudgetProgress p ON b.BudgetID = p.BudgetID AND e.CategoryID = p.CategoryID
                    WHERE b.UserID = @UID AND b.YearMonth = @YM";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@UID", CurrentUserID);
                da.SelectCommand.Parameters.AddWithValue("@YM", SelectedMonth);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptBudgetEnvelopes.DataSource = dt;
                rptBudgetEnvelopes.DataBind();

                // 3. Summaries & Alerts
                decimal totalAllocated = dt.AsEnumerable().Sum(r => r.Field<decimal>("MonthlyLimit"));
                litTotalBudgeted.Text = totalAllocated.ToString("N2");
                litRemaining.Text = (monthlyBudgetLimit - totalAllocated).ToString("N2");

                if (totalAllocated > monthlyBudgetLimit)
                {
                    pnlBudgetWarning.Visible = true;
                    litOverAmount.Text = (totalAllocated - monthlyBudgetLimit).ToString("N2");
                }
                else { pnlBudgetWarning.Visible = false; }

                litCurrentMonth.Text = DateTime.Parse(SelectedMonth + "-01").ToString("MMM yyyy");
            }
        }

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            if (ddlCategories.SelectedValue == "0" || string.IsNullOrEmpty(txtAmount.Text)) return;

            int categoryId = int.Parse(ddlCategories.SelectedValue);
            decimal amount = decimal.Parse(txtAmount.Text);

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();
                // Ensure Budget Record exists
                SqlCommand bCmd = new SqlCommand(@"
                    IF NOT EXISTS(SELECT 1 FROM Budgets WHERE UserID=@U AND YearMonth=@Y) 
                        INSERT INTO Budgets(UserID,YearMonth,TotalAmount) VALUES(@U,@Y, 0); 
                    SELECT BudgetID FROM Budgets WHERE UserID=@U AND YearMonth=@Y", conn);
                bCmd.Parameters.AddWithValue("@U", CurrentUserID);
                bCmd.Parameters.AddWithValue("@Y", SelectedMonth);
                int bid = Convert.ToInt32(bCmd.ExecuteScalar());

                // Check Duplicates
                SqlCommand checkCmd = new SqlCommand("SELECT EnvelopeID FROM BudgetEnvelopes WHERE BudgetID=@B AND CategoryID=@C", conn);
                checkCmd.Parameters.AddWithValue("@B", bid);
                checkCmd.Parameters.AddWithValue("@C", categoryId);
                object existingId = checkCmd.ExecuteScalar();

                if (existingId != null)
                {
                    string script = $"if(confirm('Category exists. Replace amount with ${amount}?')) {{ __doPostBack('ReplaceCategory', '{existingId}'); }}";
                    ScriptManager.RegisterStartupScript(this, GetType(), "confirmReplace", script, true);
                    return;
                }

                SqlCommand iCmd = new SqlCommand("INSERT INTO BudgetEnvelopes(BudgetID,CategoryID,MonthlyLimit) VALUES(@B,@C,@L)", conn);
                iCmd.Parameters.AddWithValue("@B", bid); iCmd.Parameters.AddWithValue("@C", categoryId); iCmd.Parameters.AddWithValue("@L", amount);
                iCmd.ExecuteNonQuery();
            }
            LoadGoalData();
        }

        private void ReplaceExistingCategory(int envId, decimal amt)
        {
            UpdateBudget(envId, amt);
            LoadGoalData();
        }

        protected void rptBudgetEnvelopes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "StartEdit") { EditingID = id; }
            else if (e.CommandName == "SaveEdit")
            {
                var txt = (TextBox)e.Item.FindControl("txtInlineAmount");
                if (decimal.TryParse(txt.Text, out decimal amt)) UpdateBudget(id, amt);
                EditingID = -1;
            }
            else if (e.CommandName == "DeleteCategory") { DeleteBudget(id); }
            else if (e.CommandName == "CancelEdit") { EditingID = -1; }
            LoadGoalData();
        }

        private void UpdateBudget(int id, decimal amt)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("UPDATE BudgetEnvelopes SET MonthlyLimit=@A WHERE EnvelopeID=@I", conn);
                cmd.Parameters.AddWithValue("@A", amt); cmd.Parameters.AddWithValue("@I", id);
                conn.Open(); cmd.ExecuteNonQuery();
            }
        }

        private void DeleteBudget(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM BudgetEnvelopes WHERE EnvelopeID=@I", conn);
                cmd.Parameters.AddWithValue("@I", id);
                conn.Open(); cmd.ExecuteNonQuery();
            }
        }

        // --- Standard Nav Logic ---
        protected void ChangeMonth_Click(object sender, EventArgs e)
        {
            int dir = Convert.ToInt32(((LinkButton)sender).CommandArgument);
            SelectedMonth = DateTime.Parse(SelectedMonth + "-01").AddMonths(dir).ToString("yyyy-MM");
            EditingID = -1; LoadGoalData();
        }
        protected void TogglePicker_Click(object sender, EventArgs e)
        {
            pnlPicker.Visible = !pnlPicker.Visible;
            if (pnlPicker.Visible) { mvPicker.ActiveViewIndex = 0; litPickerYear.Text = SelectedMonth.Split('-')[0]; BindMonthGrid(); }
        }
        private void BindMonthGrid()
        {
            rptMonths.DataSource = Enumerable.Range(1, 12).Select(m => new {
                MonthNum = m,
                MonthName = DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(m),
                CssClass = (SelectedMonth == $"{litPickerYear.Text}-{m:D2}") ? "grid-item active-grid-item" : "grid-item"
            }).ToList();
            rptMonths.DataBind();
        }
        protected void rptMonths_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            SelectedMonth = $"{litPickerYear.Text}-{int.Parse(e.CommandArgument.ToString()):D2}";
            pnlPicker.Visible = false; LoadGoalData();
        }
        protected void btnSwitchToYear_Click(object sender, EventArgs e) { mvPicker.ActiveViewIndex = 1; BindYearGrid(); }
        private void BindYearGrid() { rptYears.DataSource = Enumerable.Range(2020, 10).ToList(); rptYears.DataBind(); }
        protected void rptYears_ItemCommand(object source, RepeaterCommandEventArgs e) { litPickerYear.Text = e.CommandArgument.ToString(); mvPicker.ActiveViewIndex = 0; BindMonthGrid(); }
        protected void btnToday_Click(object sender, EventArgs e) { SelectedMonth = DateTime.Now.ToString("yyyy-MM"); pnlPicker.Visible = false; LoadGoalData(); }
        private void PopulateCategoryDropdown()
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName", conn);
                DataTable dt = new DataTable(); da.Fill(dt);
                ddlCategories.DataSource = dt; ddlCategories.DataTextField = "CategoryName"; ddlCategories.DataValueField = "CategoryID"; ddlCategories.DataBind();
                ddlCategories.Items.Insert(0, new ListItem("-- Select Category --", "0"));
            }
        }
    }
}