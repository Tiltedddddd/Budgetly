using System;
using System.Web;
using System.Web.UI;

namespace Budgetly.Pages
{
    public partial class settingsPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check: If session is gone, kick to login
            if (Session["UserID"] == null)
            {
                Response.Redirect("loginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // 1. Clear all session variables
            Session.Clear();

            // 2. Destroy the session identity
            Session.Abandon();

            // 3. Clear the session cookie from the browser
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-20);
            }

            // 4. Redirect to login using the "false" parameter to prevent the jump/loop error
            Response.Redirect("loginPage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}