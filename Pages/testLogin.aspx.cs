using System;
using System.Web.UI;

namespace Budgetly.Pages
{
    public partial class testLogin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: clear previous session
            if (!IsPostBack)
            {
                Session["CurrentUserID"] = null;
            }
        }

        protected void User_Click(object sender, EventArgs e)
        {
            var btn = sender as System.Web.UI.WebControls.Button;
            if (btn != null)
            {
                // Store the selected user ID in session
                int userId = int.Parse(btn.CommandArgument);
                Session["CurrentUserID"] = userId;

                // Redirect to goal setting page
                Response.Redirect("~/Pages/goalSettingPage.aspx");
            }
        }
    }
}
