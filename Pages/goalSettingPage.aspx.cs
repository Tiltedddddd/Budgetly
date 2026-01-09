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

        private int DecadeStart
        {
            get => (int)(ViewState["DecadeStart"] ?? 2020);
            set => ViewState["DecadeStart"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Note: Removed BindData() as LoadGoalData() handles the binding
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

                SqlCommand cmdInc = new SqlCommand("SELECT Amount FROM Income WHERE UserID=@UID AND YearMonth=@YM", conn);
                cmdInc.Parameters.AddWithValue("@UID", CurrentUserID);
                cmdInc.Parameters.AddWithValue("@YM", SelectedMonth);
                var resInc = cmdInc.ExecuteScalar();
                decimal income = (resInc != null && resInc != DBNull.Value) ? Convert.ToDecimal(resInc) : 0;

                litIncomeSub.Text = income.ToString("C");

                string sql = @"SELECT e.EnvelopeID, c.CategoryName, e.MonthlyLimit 
                               FROM BudgetEnvelopes e JOIN Categories c ON e.CategoryID = c.CategoryID
                               JOIN Budgets b ON e.BudgetID = b.BudgetID 
                               WHERE b.UserID = @UID AND b.YearMonth = @YM";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@UID", CurrentUserID);
                da.SelectCommand.Parameters.AddWithValue("@YM", SelectedMonth);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptBudgetEnvelopes.DataSource = dt;
                rptBudgetEnvelopes.DataBind();

                decimal total = dt.AsEnumerable().Sum(r => r.Field<decimal>("MonthlyLimit"));
                litTotalBudgeted.Text = total.ToString("N2");
                litRemaining.Text = (income - total).ToString("N2");
                litCurrentMonth.Text = DateTime.Parse(SelectedMonth + "-01").ToString("MMM yyyy");
            }
        }

        // --- Picker Logic ---
        protected void TogglePicker_Click(object sender, EventArgs e)
        {
            pnlPicker.Visible = !pnlPicker.Visible;
            if (pnlPicker.Visible)
            {
                mvPicker.ActiveViewIndex = 0;
                litPickerYear.Text = SelectedMonth.Split('-')[0];
                BindMonthGrid();
            }
        }

        private void BindMonthGrid()
        {
            var months = Enumerable.Range(1, 12).Select(m => new {
                MonthNum = m,
                MonthName = DateTimeFormatInfo.CurrentInfo.GetAbbreviatedMonthName(m),
                CssClass = (SelectedMonth == string.Format("{0}-{1:D2}", litPickerYear.Text, m)) ? "grid-item active-grid-item" : "grid-item"
            }).ToList();
            rptMonths.DataSource = months;
            rptMonths.DataBind();
        }

        protected void rptMonths_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            SelectedMonth = string.Format("{0}-{1:D2}", litPickerYear.Text, int.Parse(e.CommandArgument.ToString()));
            EditingID = -1;
            pnlPicker.Visible = false;
            LoadGoalData();
        }

        protected void btnSwitchToYear_Click(object sender, EventArgs e)
        {
            mvPicker.ActiveViewIndex = 1;
            DecadeStart = (int.Parse(litPickerYear.Text) / 10) * 10;
            BindYearGrid();
        }

        private void BindYearGrid()
        {
            litDecadeRange.Text = string.Format("{0} - {1}", DecadeStart, DecadeStart + 9);
            rptYears.DataSource = Enumerable.Range(DecadeStart, 10).ToList();
            rptYears.DataBind();
        }

        protected void rptYears_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            litPickerYear.Text = e.CommandArgument.ToString();
            mvPicker.ActiveViewIndex = 0;
            BindMonthGrid();
        }

        protected void btnToday_Click(object sender, EventArgs e)
        {
            SelectedMonth = DateTime.Now.ToString("yyyy-MM");
            pnlPicker.Visible = false;
            LoadGoalData();
        }

        protected void ChangeMonth_Click(object sender, EventArgs e)
        {
            int dir = Convert.ToInt32(((LinkButton)sender).CommandArgument);
            SelectedMonth = DateTime.Parse(SelectedMonth + "-01").AddMonths(dir).ToString("yyyy-MM");
            EditingID = -1;
            LoadGoalData();
        }

        protected void ChangeDecade_Click(object sender, EventArgs e)
        {
            DecadeStart += Convert.ToInt32(((LinkButton)sender).CommandArgument);
            BindYearGrid();
        }

        // --- Action Methods (Add, Edit, Delete) ---
        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            if (ddlCategories.SelectedValue == "0" || string.IsNullOrEmpty(txtAmount.Text))
            {
                ShowStatus("Missing info!", "msg-error"); // Red for error
                return;
            }
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();
                SqlCommand bCmd = new SqlCommand("IF NOT EXISTS(SELECT 1 FROM Budgets WHERE UserID=@U AND YearMonth=@Y) INSERT INTO Budgets(UserID,YearMonth) VALUES(@U,@Y); SELECT BudgetID FROM Budgets WHERE UserID=@U AND YearMonth=@Y", conn);
                bCmd.Parameters.AddWithValue("@U", CurrentUserID); bCmd.Parameters.AddWithValue("@Y", SelectedMonth);
                int bid = Convert.ToInt32(bCmd.ExecuteScalar());

                SqlCommand iCmd = new SqlCommand("INSERT INTO BudgetEnvelopes(BudgetID,CategoryID,MonthlyLimit) VALUES(@B,@C,@L)", conn);
                iCmd.Parameters.AddWithValue("@B", bid);
                iCmd.Parameters.AddWithValue("@C", ddlCategories.SelectedValue);
                iCmd.Parameters.AddWithValue("@L", decimal.Parse(txtAmount.Text));
                iCmd.ExecuteNonQuery();
            }

            txtAmount.Text = ""; // Clear input
            ShowStatus("Added successfully!", "msg-success"); // Green
            LoadGoalData();
        }

        protected void rptBudgetEnvelopes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "StartEdit") { EditingID = id; LoadGoalData(); }
            else if (e.CommandName == "CancelEdit") { EditingID = -1; LoadGoalData(); }
            else if (e.CommandName == "SaveEdit")
            {
                var txt = (TextBox)e.Item.FindControl("txtInlineAmount");
                if (decimal.TryParse(txt.Text, out decimal amt))
                {
                    UpdateBudget(id, amt);
                    EditingID = -1;
                    ShowStatus("Changes saved!", "msg-info"); // Blue
                    LoadGoalData();
                }
            }
            else if (e.CommandName == "DeleteCategory")
            {
                DeleteBudget(id);
                ShowStatus("Category deleted.", "msg-error"); // Red
                LoadGoalData();
            }
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

        // --- The Fixed ShowStatus Method ---
        private void ShowStatus(string msg, string colorClass)
        {
            lblStatus.Text = msg;
            lblStatus.Visible = true;
            // Uses the CSS classes: msg-success, msg-info, msg-error
            lblStatus.CssClass = "status-message " + colorClass;

            // Calls the Javascript to vanish
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMsg", "hideNotification();", true);
        }

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