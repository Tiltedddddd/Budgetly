using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Budgetly.Pages
{
    public partial class walletsPage : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Load_Wallets();
            }
        }


        protected void Load_Wallets()
        {

        }

        protected void btn_Createwallet_Click(object sender, EventArgs e)
        {

        }

        protected void btn_Cancel_Click(object sender, EventArgs e)
        {
            pn_AddWallet.Visible = false;
        }

        protected void btn_addCard_Click(object sender, EventArgs e)
        {
            pn_AddWallet.Visible = true;
        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}