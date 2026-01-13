using System;
using System.Web.UI;

namespace Budgetly.Pages
{
    public partial class dashboard : Page
    {
        public string CurrentUserName { get; set; }
        public int CurrentUserId { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Check if user is logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("loginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            try
            {
                // 2. Load User Data from Session
                if (int.TryParse(Session["UserID"].ToString(), out int userId))
                {
                    CurrentUserId = userId;
                }
                CurrentUserName = Session["UserName"]?.ToString() ?? "User";

                // 3. Inject UserID into Frontend for API calls
                if (!IsPostBack)
                {
                    // This creates a global JS variable 'loggedInUserId'
                    string script = $"var loggedInUserId = {CurrentUserId};";
                    ClientScript.RegisterStartupScript(this.GetType(), "UserData", script, true);
                }
            }
            catch (Exception)
            {
                // Safety fallback
                Session.Clear();
                Response.Redirect("loginPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("loginPage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}