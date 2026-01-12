using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Budgetly
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string path = Request.AppRelativeCurrentExecutionFilePath;

            if (path.Contains("dashboard.aspx"))
                navDashboard.Attributes["class"] += " is-active";
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

        }
    }
}