using System;
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

        private int CurrentUserID
        {
            get
            {
                if (Session["CurrentUserID"] == null)
                    Response.Redirect("~/Pages/testLogin.aspx");
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
        private const string GoalSettingIncomeSource = "GoalSetting";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlIncomeEdit.Visible = false;
                pnlBudgetEdit.Visible = false;

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

                // ✅ Income is SUM from SQL
                SqlCommand cmdData = new SqlCommand(@"
            SELECT 
                ISNULL((SELECT SUM(Amount) FROM Income WHERE UserID=@UID AND YearMonth=@YM), 0) as FixedIncome,
                ISNULL((SELECT TotalAmount FROM Budgets WHERE UserID=@UID AND YearMonth=@YM), 0) as BudgetLimit
        ", conn);

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

                // Display
                litIncomeSub.Text = fixedIncome.ToString("N2");
                litBudgetAmount.Text = monthlyBudgetLimit.ToString("N2");

                // ✅ always Update (never Add)
                btnIncomeAction.Text = "Update Income";
                btnBudgetLimitAction.Text = "Update Budget Limit";

                // Prefill edit inputs from SQL values
                txtIncomeEdit.Text = fixedIncome.ToString("0.00", CultureInfo.InvariantCulture);
                txtBudgetLimitEdit.Text = monthlyBudgetLimit.ToString("0.00", CultureInfo.InvariantCulture);

                // Envelopes (same as your code)
                string sqlEnvelopes = @"
            SELECT 
                e.EnvelopeID, 
                e.CategoryID,
                c.CategoryName, 
                e.MonthlyLimit,
                ISNULL(p.SpentAmount, 0) as SpentAmount,
                (e.MonthlyLimit - ISNULL(p.SpentAmount, 0)) as RemainingAmount
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


        protected void btnIncomeAction_Click(object sender, EventArgs e)
        {
            pnlBudgetEdit.Visible = false;
            pnlIncomeEdit.Visible = true;
        }

        protected void btnBudgetLimitAction_Click(object sender, EventArgs e)
        {
            pnlIncomeEdit.Visible = false;
            pnlBudgetEdit.Visible = true;
        }

        protected void btnCancelIncome_Click(object sender, EventArgs e)
        {
            pnlIncomeEdit.Visible = false;
        }

        protected void btnCancelBudgetLimit_Click(object sender, EventArgs e)
        {
            pnlBudgetEdit.Visible = false;
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

                // Categories in current month for PLANNER
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

        // Fix: add step to the asp:TextBox rendered as number input
        protected void rptBudgetEnvelopes_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var tb = e.Item.FindControl("txtInlineAmount") as TextBox;
                if (tb != null)
                {
                    tb.Attributes["step"] = "0.01";
                    tb.Attributes["min"] = "0";
                }
            }
        }

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
        protected void btnSaveIncome_Click(object sender, EventArgs e)
        {
            // Allow commas like 2,500.00
            var raw = (txtIncomeEdit.Text ?? "").Trim().Replace(",", "");

            if (!decimal.TryParse(raw, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal amt))
            {
                ShowNotification("Income must be a valid number.", "", "warning");
                return;
            }

            if (amt <= 0)
            {
                ShowNotification("Income must be more than 0.", "", "warning");
                return;
            }

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // ✅ HARD REPLACE: remove all income rows for that month
                        SqlCommand del = new SqlCommand(@"
                    DELETE FROM Income
                    WHERE UserID = @UID AND YearMonth = @YM;
                ", conn, tx);

                        del.Parameters.AddWithValue("@UID", CurrentUserID);
                        del.Parameters.AddWithValue("@YM", SelectedMonth);
                        del.ExecuteNonQuery();

                        // ✅ Insert exactly ONE row so SUM = typed amount
                        SqlCommand ins = new SqlCommand(@"
                    INSERT INTO Income (UserID, YearMonth, Amount, Source)
                    VALUES (@UID, @YM, @AMT, @SRC);
                ", conn, tx);

                        ins.Parameters.AddWithValue("@UID", CurrentUserID);
                        ins.Parameters.AddWithValue("@YM", SelectedMonth);
                        ins.Parameters.AddWithValue("@AMT", amt);
                        ins.Parameters.AddWithValue("@SRC", "GoalSetting");
                        ins.ExecuteNonQuery();

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        ShowNotification("Income update failed. Try again.", "", "warning");
                        return;
                    }
                }
            }

            // ✅ If budget limit must be <= income, clamp it down if needed
            decimal currentBudgetLimit = 0;
            decimal monthIncome = 0;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                SqlCommand getIncome = new SqlCommand(@"
            SELECT ISNULL(SUM(Amount),0)
            FROM Income
            WHERE UserID=@UID AND YearMonth=@YM;
        ", conn);

                getIncome.Parameters.AddWithValue("@UID", CurrentUserID);
                getIncome.Parameters.AddWithValue("@YM", SelectedMonth);
                monthIncome = Convert.ToDecimal(getIncome.ExecuteScalar());

                SqlCommand getBudget = new SqlCommand(@"
            SELECT ISNULL(TotalAmount,0)
            FROM Budgets
            WHERE UserID=@UID AND YearMonth=@YM;
        ", conn);

                getBudget.Parameters.AddWithValue("@UID", CurrentUserID);
                getBudget.Parameters.AddWithValue("@YM", SelectedMonth);
                object budObj = getBudget.ExecuteScalar();
                currentBudgetLimit = (budObj == null) ? 0 : Convert.ToDecimal(budObj);

                if (currentBudgetLimit > monthIncome)
                {
                    SqlCommand updBudget = new SqlCommand(@"
                UPDATE Budgets
                SET TotalAmount=@L
                WHERE UserID=@UID AND YearMonth=@YM;
            ", conn);

                    updBudget.Parameters.AddWithValue("@UID", CurrentUserID);
                    updBudget.Parameters.AddWithValue("@YM", SelectedMonth);
                    updBudget.Parameters.AddWithValue("@L", monthIncome);
                    updBudget.ExecuteNonQuery();
                }
            }

            pnlIncomeEdit.Visible = false;
            LoadGoalData();
            ShowNotification("Income updated!", "", "success");
        }


        protected void btnSaveBudgetLimit_Click(object sender, EventArgs e)
        {
            if (!decimal.TryParse(txtBudgetLimitEdit.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal limit))
            {
                ShowNotification("Budget limit must be a valid number.", "", "warning");
                return;
            }
            if (limit < 0)
            {
                ShowNotification("Budget limit cannot be negative.", "", "warning");
                return;
            }

            // ✅ read income from SQL (SUM) and validate budget <= income
            decimal monthIncome = 0;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                SqlCommand getIncome = new SqlCommand(@"
            SELECT ISNULL(SUM(Amount),0)
            FROM Income
            WHERE UserID=@UID AND YearMonth=@YM
        ", conn);

                getIncome.Parameters.AddWithValue("@UID", CurrentUserID);
                getIncome.Parameters.AddWithValue("@YM", SelectedMonth);

                monthIncome = Convert.ToDecimal(getIncome.ExecuteScalar());

                if (limit > monthIncome)
                {
                    ShowNotification($"Budget limit cannot exceed income (${monthIncome:N2}).", "", "warning");
                    return;
                }

                // ✅ Replace/Upsert Budgets row
                SqlCommand cmd = new SqlCommand(@"
            IF EXISTS (SELECT 1 FROM Budgets WHERE UserID=@UID AND YearMonth=@YM)
            BEGIN
                UPDATE Budgets
                SET TotalAmount=@L
                WHERE UserID=@UID AND YearMonth=@YM;
            END
            ELSE
            BEGIN
                INSERT INTO Budgets(UserID, YearMonth, TotalAmount)
                VALUES(@UID, @YM, @L);
            END
        ", conn);

                cmd.Parameters.AddWithValue("@UID", CurrentUserID);
                cmd.Parameters.AddWithValue("@YM", SelectedMonth);
                cmd.Parameters.AddWithValue("@L", limit);

                cmd.ExecuteNonQuery();
            }

            pnlBudgetEdit.Visible = false;
            LoadGoalData();
            ShowNotification("Budget limit updated!", "", "success");
        }


        protected void btnCopyLastMonth_Click(object sender, EventArgs e)
        {
            DateTime currentDt = DateTime.Parse(SelectedMonth + "-01");
            string lastYM = currentDt.AddMonths(-1).ToString("yyyy-MM");

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

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
            if (ddlCategories.SelectedValue == "0" || string.IsNullOrWhiteSpace(txtAmount.Text))
                return;

            int categoryId = int.Parse(ddlCategories.SelectedValue);
            decimal amount = decimal.Parse(txtAmount.Text, CultureInfo.InvariantCulture);

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                // Ensure budget exists + get BudgetID
                SqlCommand bCmd = new SqlCommand(@"
                    IF NOT EXISTS (SELECT 1 FROM Budgets WHERE UserID=@U AND YearMonth=@Y)
                        INSERT INTO Budgets(UserID, YearMonth, TotalAmount) VALUES(@U, @Y, 0);

                    SELECT BudgetID FROM Budgets WHERE UserID=@U AND YearMonth=@Y;", conn);

                bCmd.Parameters.AddWithValue("@U", CurrentUserID);
                bCmd.Parameters.AddWithValue("@Y", SelectedMonth);
                int budgetId = Convert.ToInt32(bCmd.ExecuteScalar());

                // Check if category exists
                SqlCommand checkCmd = new SqlCommand(@"
                    SELECT EnvelopeID
                    FROM BudgetEnvelopes
                    WHERE BudgetID=@B AND CategoryID=@C;", conn);

                checkCmd.Parameters.AddWithValue("@B", budgetId);
                checkCmd.Parameters.AddWithValue("@C", categoryId);

                object existingEnvId = checkCmd.ExecuteScalar();

                if (existingEnvId != null)
                {
                    int envId = Convert.ToInt32(existingEnvId);
                    string amtJs = amount.ToString("0.00", CultureInfo.InvariantCulture);

                    string script = $@"
                        if (confirm('Category exists. Replace amount with ${amtJs}?')) {{
                            document.getElementById('{hfReplaceEnvId.ClientID}').value = '{envId}';
                            document.getElementById('{hfReplaceAmt.ClientID}').value = '{amtJs}';
                            __doPostBack('{btnReplaceHidden.UniqueID}', '');
                        }}";

                    ScriptManager.RegisterStartupScript(this, GetType(), "confirmReplace", script, true);
                    return;
                }

                // Insert new envelope
                SqlCommand insertCmd = new SqlCommand(@"
                    INSERT INTO BudgetEnvelopes (BudgetID, CategoryID, MonthlyLimit)
                    VALUES (@B, @C, @L);", conn);

                insertCmd.Parameters.AddWithValue("@B", budgetId);
                insertCmd.Parameters.AddWithValue("@C", categoryId);
                insertCmd.Parameters.AddWithValue("@L", amount);
                insertCmd.ExecuteNonQuery();
            }

            LoadGoalData();

            txtAmount.Text = "";
            ddlCategories.SelectedIndex = 0;

            ShowNotification("Category added successfully!", "", "success");
            ScriptManager.RegisterStartupScript(this, GetType(), "hideAddForm", "toggleAddForm(false);", true);
        }

        protected void btnReplaceHidden_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hfReplaceEnvId.Value, out int envId)) return;
            if (!decimal.TryParse(hfReplaceAmt.Value, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal amt)) return;

            UpdateBudget(envId, amt);
            LoadGoalData();

            txtAmount.Text = "";
            ddlCategories.SelectedIndex = 0;

            ShowNotification("Category updated successfully!", "", "success");
            ScriptManager.RegisterStartupScript(this, GetType(), "hideAddForm", "toggleAddForm(false);", true);
        }

        protected void rptBudgetEnvelopes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = -1;
            if (e.CommandArgument != null && int.TryParse(e.CommandArgument.ToString(), out int parsed))
                id = parsed;

            if (e.CommandName == "StartEdit")
            {
                EditingID = id;
            }
            else if (e.CommandName == "SaveEdit")
            {
                var txt = (TextBox)e.Item.FindControl("txtInlineAmount");
                if (txt != null && decimal.TryParse(txt.Text, out decimal amt))
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
                EditingID = -1;
            }
            else if (e.CommandName == "CancelEdit")
            {
                EditingID = -1;
            }

            LoadGoalData();
        }

        private void UpdateBudget(int envId, decimal amt)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand(@"
                    UPDATE BudgetEnvelopes
                    SET MonthlyLimit = @L
                    WHERE EnvelopeID = @E;", conn);

                cmd.Parameters.AddWithValue("@L", amt);
                cmd.Parameters.AddWithValue("@E", envId);
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
            rptMonths.DataSource = Enumerable.Range(1, 12).Select(m => new
            {
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

        protected void btnImplement_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hfProjectedCatID.Value, out int catId) || catId <= 0) return;
            if (!decimal.TryParse(hfProjectedValue.Value, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal newValue)) return;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();

                SqlCommand bCmd = new SqlCommand(@"
                    IF NOT EXISTS(SELECT 1 FROM Budgets WHERE UserID=@UID AND YearMonth=@YM)
                        INSERT INTO Budgets(UserID,YearMonth,TotalAmount) VALUES(@UID,@YM,0);

                    SELECT BudgetID FROM Budgets WHERE UserID=@UID AND YearMonth=@YM;", conn);

                bCmd.Parameters.AddWithValue("@UID", CurrentUserID);
                bCmd.Parameters.AddWithValue("@YM", SelectedMonth);
                int budgetId = Convert.ToInt32(bCmd.ExecuteScalar());

                SqlCommand updEnv = new SqlCommand(@"
                    UPDATE BudgetEnvelopes
                    SET MonthlyLimit = @Val
                    WHERE BudgetID = @BID AND CategoryID = @CID;", conn);

                updEnv.Parameters.AddWithValue("@Val", newValue);
                updEnv.Parameters.AddWithValue("@BID", budgetId);
                updEnv.Parameters.AddWithValue("@CID", catId);
                updEnv.ExecuteNonQuery();

                SqlCommand updProgress = new SqlCommand(@"
                    IF EXISTS (SELECT 1 FROM BudgetProgress WHERE BudgetID=@BID AND CategoryID=@CID)
                    BEGIN
                        UPDATE BudgetProgress
                        SET RemainingAmount = (@Val - ISNULL(SpentAmount,0))
                        WHERE BudgetID=@BID AND CategoryID=@CID;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO BudgetProgress (BudgetID, CategoryID, SpentAmount, RemainingAmount)
                        VALUES (@BID, @CID, 0, @Val);
                    END", conn);

                updProgress.Parameters.AddWithValue("@BID", budgetId);
                updProgress.Parameters.AddWithValue("@CID", catId);
                updProgress.Parameters.AddWithValue("@Val", newValue);
                updProgress.ExecuteNonQuery();
            }

            LoadGoalData();
            PopulateCategoryDropdowns();

            ShowNotification("Budget updated successfully!", "", "success");
            ScriptManager.RegisterStartupScript(this, GetType(), "closePlanner", "closePlanner();", true);

            hfProjectedCatID.Value = "0";
            hfProjectedValue.Value = "0";
        }
        protected void ChangeYear_Click(object sender, EventArgs e)
        {
            int dir = Convert.ToInt32(((LinkButton)sender).CommandArgument); // -1 or +1

            // Use the year currently shown in picker
            int year = int.Parse(litPickerYear.Text);

            year += dir;
            litPickerYear.Text = year.ToString();

            // Keep the same selected month number, just swap year
            int currentMonthNum = int.Parse(SelectedMonth.Split('-')[1]); // "yyyy-MM"
            string newYM = $"{year}-{currentMonthNum:D2}";

            // Update selection + refresh month grid highlight
            SelectedMonth = newYM;

            // Stay in month view
            mvPicker.ActiveViewIndex = 0;
            BindMonthGrid();

            // Refresh main page numbers/table (optional but usually expected)
            LoadGoalData();
        }


        private void ShowNotification(string message, string icon, string cssClass)
        {
            lblStatus.Text = message;

            string script = $@"
                var toast = document.getElementById('customToast');
                var iconSpan = document.getElementById('toastIcon');
                if(toast) {{
                    iconSpan.style.display = 'none';
                    toast.className = 'planner-toast ' + '{cssClass}';
                    toast.style.display = 'flex';
                    setTimeout(function() {{ toast.style.display = 'none'; }}, 3000);
                }}";

            ScriptManager.RegisterStartupScript(this, GetType(), "showToast", script, true);
        }
        protected void cvBudgetVsIncome_ServerValidate(object source, ServerValidateEventArgs args)
        {
            // If budget is not a number, let regex validator handle it
            if (!decimal.TryParse(txtBudgetLimitEdit.Text, out decimal budget))
            {
                args.IsValid = true;
                return;
            }

            // income source: current month income from DB (same logic as LoadGoalData)
            decimal income = 0m;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connStringName].ConnectionString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
            SELECT ISNULL(SUM(Amount), 0)
            FROM Income
            WHERE UserID=@UID AND YearMonth=@YM", conn);
                cmd.Parameters.AddWithValue("@UID", CurrentUserID);
                cmd.Parameters.AddWithValue("@YM", SelectedMonth);

                income = Convert.ToDecimal(cmd.ExecuteScalar());
            }

            args.IsValid = (budget <= income);
        }

    }
}
