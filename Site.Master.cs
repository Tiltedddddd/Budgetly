using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Budgetly
{
    public partial class Site : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            string path = Request.AppRelativeCurrentExecutionFilePath;

            if (path.Contains("homePage.aspx"))
                navHome.Attributes["class"] += " is-active";
            else if (path.Contains("analyticsPage.aspx"))
                navAnalytics.Attributes["class"] += " is-active";
            else if (path.Contains("transactionsPage.aspx"))
                navTransactions.Attributes["class"] += " is-active";
            else if (path.Contains("walletsPage.aspx"))
                navWallets.Attributes["class"] += " is-active";
            else if (path.Contains("denPage.aspx"))
                navDen.Attributes["class"] += " is-active";
            else if (path.Contains("goalSettingPage.aspx"))
                navGoalSetting.Attributes["class"] += " is-active";
            else if (path.Contains("settingsPage.aspx"))
                navSettings.Attributes["class"] += " is-active";
            else if (path.Contains("CRUDData.aspx"))
                navCRUD.Attributes["class"] += " is-active";
            else if (path.Contains("viewData.aspx"))
                navViewData.Attributes["class"] += " is-active";

            if (!IsPostBack)
            {
                LoadUsers();
                EnsureUserSelected();
                SyncDropdown();
            }
        }
        private void LoadUsers()
        {
            ddlUsers.Items.Clear();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd =
                new SqlCommand(
                    "SELECT UserID, FullName FROM Users WHERE IsActive = 1 ORDER BY FullName",
                    conn))
            {
                conn.Open();
                ddlUsers.DataSource = cmd.ExecuteReader();
                ddlUsers.DataValueField = "UserID";
                ddlUsers.DataTextField = "FullName";
                ddlUsers.DataBind();
            }
        }

        /// <summary>
        /// Guarantees Session["UserID"] exists and is an INT
        /// </summary>
        private void EnsureUserSelected()
        {
            if (Session["UserID"] == null && ddlUsers.Items.Count > 0)
            {
                Session["UserID"] = int.Parse(ddlUsers.Items[0].Value);
            }
        }

        protected void ddlUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            // ✅ Update session from dropdown
            Session["UserID"] = int.Parse(ddlUsers.SelectedValue);

            // 🔄 Reload page so all content pages pick it up
            Response.Redirect(Request.RawUrl);
        }

        /// <summary>
        /// Sync dropdown + label from Session
        /// ONLY called on first load
        /// </summary>
        private void SyncDropdown()
        {
            if (Session["FullName"] == null)
                return;

            string fullname = Session["FullName"].ToString();

            if (ddlUsers.Items.FindByValue(fullname) != null)
            {
                ddlUsers.SelectedValue = fullname;
                welcomeuser.InnerText = $"{fullname}";
            }
        }

    }
}