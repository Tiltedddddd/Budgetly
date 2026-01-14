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
    public partial class goalSettingPage : Page
    {
        private readonly string connStringName = "BudgetlyDBContext";

        // Get current user from session
        private int CurrentUserID
        {
            get
            {
                if (Session["CurrentUserID"] == null)
                    Response.Redirect("~/Pages/testLogin.aspx"); // redirect if no user
                return Convert.ToInt32(Session["CurrentUserID"]);
            }
        }

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
            if (!IsPostBack)
            {
                LoadGoalData();
                PopulateCategoryDropdowns();
            }
        }

        private void LoadGoalData()
        {
            string connStr = ConfigurationManager.ConnectionStrings[connStringName].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Fetch Income and Global Budget Limit
                SqlCommand cmdData = new SqlCommand(@"
                    SELECT 
                        ISNULL((SELECT SUM(Amount) FROM Income WHERE UserID=@UID AND YearMonth=@YM), 0) as FixedIncome,
                        ISNULL((SELECT TotalAmount FROM Budgets WHERE UserID=@UID AND YearMonth=@YM), 0) as BudgetLimit", conn);
                cmdData.Parameters.AddWithValue("@UID", CurrentUserID);
                cmdData.Parameters.AddWithValue("@YM", SelectedMonth);

                decimal fixedIncome = 0;
                decimal monthlyBudgetLimit = 0;

                using (SqlDataReader reader = cmdData.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        fixedIncome = Convert.ToDecimal(reader["FixedIncome"]);
                        monthlyBudgetLimit = Convert.ToDecimal(reader["BudgetLimit"]);
                    }
                }

                litIncomeSub.Text = fixedIncome.ToString("N2");
                litBudgetAmount.Text = monthlyBudgetLimit.ToString("N2");

                // Fetch Budget Envelopes
                string sqlEnvelopes = @"
                    SELECT 
                        e.EnvelopeID, 
                        e.CategoryID,
                        c.CategoryName, 
                        e.MonthlyLimit,
                        ISNULL(p.SpentAmount, 0) as SpentAmount,
                        ISNULL(p.RemainingAmount, e.MonthlyLimit) as RemainingAmount
                    FROM BudgetEnvelopes e 
                    JOIN Categories c ON e.CategoryID = c.CategoryID
                    JOIN Budgets b ON e.BudgetID = b.BudgetID 
                    LEFT JOIN BudgetProgress p ON b.BudgetID = p.BudgetID AND e.CategoryID = p.CategoryID
                    WHERE b.UserID = @UID AND b.YearMonth = @YM";

                SqlDataAdapter da = new SqlDataAdapter(sqlEnvelopes, conn);
                da.SelectCommand.Parameters.AddWithValue("@UID", CurrentUserID);
                da.SelectCommand.Parameters.AddWithValue("@YM", SelectedMonth);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptBudgetEnvelopes.DataSource = dt;
                rptBudgetEnvelopes.DataBind();

                decimal totalAllocated = dt.AsEnumerable().Sum(r => r.Field<decimal>("MonthlyLimit"));
                litTotalBudgeted.Text = totalAllocated.ToString("N2");
                litRemaining.Text = (monthlyBudgetLimit - totalAllocated).ToString("N2");

                // Over-Budget Warning
                if (totalAllocated > monthlyBudgetLimit)
                {
                    pnlBudgetWarning.Visible = true;
                    litOverAmount.Text = (totalAllocated - monthlyBudgetLimit).ToString("N2");
                }
                else
                {
                    pnlBudgetWarning.Visible = false;
                }

                litCurrentMonth.Text = DateTime.Parse(SelectedMonth + "-01").ToString("MMM yyyy");
            }
        }

        protected void PopulateCategoryDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                // All categories for ADD
                SqlDataAdapter daAll = new SqlDataAdapter("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName", conn);
                DataTable dtAll = new DataTable();
                daAll.Fill(dtAll);
                ddlCategories.DataSource = dtAll;
                ddlCategories.DataTextField = "CategoryName";
                ddlCategories.DataValueField = "CategoryID";
                ddlCategories.DataBind();
                ddlCategories.Items.Insert(0, new ListItem("-- Select Category --", "0"));

                // Categories in current month's envelopes for PLANNER
                string sqlActive = @"
                    SELECT c.CategoryID, c.CategoryName 
                    FROM Categories c
                    JOIN BudgetEnvelopes e ON c.CategoryID = e.CategoryID
                    JOIN Budgets b ON e.BudgetID = b.BudgetID
                    WHERE b.UserID = @UID AND b.YearMonth = @YM
                    ORDER BY c.CategoryName";

                SqlCommand cmdActive = new SqlCommand(sqlActive, conn);
                cmdActive.Parameters.AddWithValue("@UID", CurrentUserID);
                cmdActive.Parameters.AddWithValue("@YM", SelectedMonth);

                SqlDataAdapter daActive = new SqlDataAdapter(cmdActive);
                DataTable dtActive = new DataTable();
                daActive.Fill(dtActive);

                ddlPlannerCats.DataSource = dtActive;
                ddlPlannerCats.DataTextField = "CategoryName";
                ddlPlannerCats.DataValueField = "CategoryID";
                ddlPlannerCats.DataBind();
                ddlPlannerCats.Items.Insert(0, new ListItem("--Category--", "0"));
            }
        }

        // Keep your other methods (btnAddCategory_Click, rptBudgetEnvelopes_ItemCommand, UpdateBudget, etc.)
        // just ensure anywhere you use a user ID, replace with CurrentUserID
    
protected string GetProgressWidth(object spent, object limit)
        {
            decimal s = Convert.ToDecimal(spent);
            decimal l = Convert.ToDecimal(limit);
            if (l <= 0) return "0";
            decimal percent = (s / l) * 100;
            return (percent > 100 ? 100 : percent).ToString("0");
        }

        protected string GetHealthClass(object spent, object limit)
        {
            decimal s = Convert.ToDecimal(spent);
            decimal l = Convert.ToDecimal(limit);
            if (l <= 0) return "bg-safe";
            decimal ratio = s / l;
            if (ratio <= 0.7m) return "bg-safe";
            if (ratio <= 0.9m) return "bg-warning";
            return "bg-danger pulse";
        }

        protected void btnCopyLastMonth_Click(object sender, EventArgs e)
        {
            DateTime currentDt = DateTime.Parse(SelectedMonth + "-01");
            string lastYM = currentDt.AddMonths(-1).ToString("yyyy-MM");

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                // Ensure current month budget exists
                SqlCommand ensureBudget = new SqlCommand(@"
            IF NOT EXISTS(SELECT 1 FROM Budgets WHERE UserID=@UID AND YearMonth=@Cur)
                INSERT INTO Budgets(UserID, YearMonth, TotalAmount) VALUES(@UID, @Cur, 0);", conn);
                ensureBudget.Parameters.AddWithValue("@UID", CurrentUserID);
                ensureBudget.Parameters.AddWithValue("@Cur", SelectedMonth);
                ensureBudget.ExecuteNonQuery();

                string sql = @"
            INSERT INTO BudgetEnvelopes (BudgetID, CategoryID, MonthlyLimit)
            SELECT 
                (SELECT BudgetID FROM Budgets WHERE UserID=@UID AND YearMonth=@Cur), 
                CategoryID, 
                MonthlyLimit
            FROM BudgetEnvelopes 
            WHERE BudgetID = (SELECT BudgetID FROM Budgets WHERE UserID=@UID AND YearMonth=@Prev)
              AND CategoryID NOT IN (
                  SELECT CategoryID FROM BudgetEnvelopes 
                  WHERE BudgetID = (SELECT BudgetID FROM Budgets WHERE UserID=@UID AND YearMonth=@Cur)
              )";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@UID", CurrentUserID);
                cmd.Parameters.AddWithValue("@Cur", SelectedMonth);
                cmd.Parameters.AddWithValue("@Prev", lastYM);
                cmd.ExecuteNonQuery();
            }

            LoadGoalData();
        }

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            if (ddlCategories.SelectedValue == "0" || string.IsNullOrEmpty(txtAmount.Text)) return;

            int categoryId = int.Parse(ddlCategories.SelectedValue);
            decimal amount = decimal.Parse(txtAmount.Text);

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                SqlCommand bCmd = new SqlCommand(@"
            IF NOT EXISTS(SELECT 1 FROM Budgets WHERE UserID=@U AND YearMonth=@Y) 
                INSERT INTO Budgets(UserID,YearMonth,TotalAmount) VALUES(@U,@Y, 0); 
            SELECT BudgetID FROM Budgets WHERE UserID=@U AND YearMonth=@Y", conn);
                bCmd.Parameters.AddWithValue("@U", CurrentUserID);
                bCmd.Parameters.AddWithValue("@Y", SelectedMonth);
                int bid = Convert.ToInt32(bCmd.ExecuteScalar());

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
                iCmd.Parameters.AddWithValue("@B", bid);
                iCmd.Parameters.AddWithValue("@C", categoryId);
                iCmd.Parameters.AddWithValue("@L", amount);
                iCmd.ExecuteNonQuery();
            }

            // 1. Refresh the table
            LoadGoalData();

            // 2. Clear the inputs
            txtAmount.Text = "";
            ddlCategories.SelectedIndex = 0;

            // 3. Show notification (No emoji)
            ShowNotification("Category added successfully!", "", "success");

            // 4. Force the Add Form to close/hide
            ScriptManager.RegisterStartupScript(this, GetType(), "hideAddForm", "toggleAddForm(false);", true);
        }

        private void ReplaceExistingCategory(int envId, decimal amt)
        {
            UpdateBudget(envId, amt);
            LoadGoalData();
        }

        protected void rptBudgetEnvelopes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "StartEdit")
            {
                EditingID = id;
            }
            else if (e.CommandName == "SaveEdit")
            {
                var txt = (TextBox)e.Item.FindControl("txtInlineAmount");
                if (decimal.TryParse(txt.Text, out decimal amt))
                {
                    UpdateBudget(id, amt);
                    ShowNotification("Budget updated!", "", "info");
                }
                EditingID = -1;
            }
            else if (e.CommandName == "DeleteCategory")
            {
                DeleteBudget(id);
                ShowNotification("Category removed.", "", "warning");
            }
            else if (e.CommandName == "CancelEdit")
            {
                EditingID = -1;
            }
            LoadGoalData();
        }

        private void UpdateBudget(int id, decimal amt)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("UPDATE BudgetEnvelopes SET MonthlyLimit=@A WHERE EnvelopeID=@I", conn);
                cmd.Parameters.AddWithValue("@A", amt);
                cmd.Parameters.AddWithValue("@I", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void DeleteBudget(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM BudgetEnvelopes WHERE EnvelopeID=@I", conn);
                cmd.Parameters.AddWithValue("@I", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // --- Date Picker & Navigation Logic ---

        protected void ChangeMonth_Click(object sender, EventArgs e)
        {
            int dir = Convert.ToInt32(((LinkButton)sender).CommandArgument);
            SelectedMonth = DateTime.Parse(SelectedMonth + "-01").AddMonths(dir).ToString("yyyy-MM");
            EditingID = -1;
            LoadGoalData();
        }

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
            pnlPicker.Visible = false;
            LoadGoalData();
        }

        protected void btnSwitchToYear_Click(object sender, EventArgs e)
        {
            mvPicker.ActiveViewIndex = 1;
            BindYearGrid();
        }

        private void BindYearGrid()
        {
            rptYears.DataSource = Enumerable.Range(2020, 10).ToList();
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

        // --- Dropdown Management ---
        protected void btnImplement_Click(object sender, EventArgs e)
        {
            // Validate hidden field values
            if (!int.TryParse(hfProjectedCatID.Value, out int catId)) return;
            if (!decimal.TryParse(hfProjectedValue.Value, out decimal newValue)) return;

            // Update database
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();
                string sql = catId == 0
                    ? "UPDATE Budgets SET TotalAmount = @Val WHERE UserID=@UID AND YearMonth=@YM"
                    : @"UPDATE BudgetEnvelopes SET MonthlyLimit = @Val 
                WHERE CategoryID = @CID 
                AND BudgetID = (SELECT BudgetID FROM Budgets WHERE UserID=@UID AND YearMonth=@YM)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Val", newValue);
                if (catId != 0) cmd.Parameters.AddWithValue("@CID", catId);
                cmd.Parameters.AddWithValue("@UID", CurrentUserID);
                cmd.Parameters.AddWithValue("@YM", SelectedMonth);
                cmd.ExecuteNonQuery();
            }

            // Refresh UI
            LoadGoalData();
            PopulateCategoryDropdowns();

            // Show success toast
            ShowNotification("Budget updated successfully!", "💡", "success");

            // Auto-close the planner modal after 1 second
            string script = @"
        setTimeout(function() {
            togglePlanner(); // make sure this function hides the modal
        }, 1000);
    ";
            ScriptManager.RegisterStartupScript(this, GetType(), "closePlanner", "closePlanner();", true);
        }


        private void ShowNotification(string message, string icon, string cssClass)
        {
            lblStatus.Text = message;
            string script = $@"
        var toast = document.getElementById('customToast');
        var iconSpan = document.getElementById('toastIcon');
        if(toast) {{
            // icon is empty string now per your request
            iconSpan.style.display = 'none'; 
            toast.className = 'planner-toast ' + '{cssClass}';
            toast.style.display = 'flex';
            setTimeout(function() {{ toast.style.display = 'none'; }}, 3000);
        }}";
            ScriptManager.RegisterStartupScript(this, GetType(), "showToast", script, true);
        }

    }
}