using System;
using System.Web.UI.WebControls;

namespace Budgetly.Pages
{
    public partial class DevLogin : System.Web.UI.Page
    {
        protected void SwitchUser(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string userId = btn.CommandArgument; // e.g., "1" for Alice

            // Set session variables based on your SQL sample data
            Session["UserID"] = userId;

            // Redirect to your goal setting page
            Response.Redirect("goalSettingPage.aspx");
        }
    }
}