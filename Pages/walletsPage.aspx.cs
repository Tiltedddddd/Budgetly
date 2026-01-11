using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Budgetly.Pages
{
    public partial class walletsPage : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        int CurrentUserId
        {
            get
            {
                if (Session["UserID"] == null)
                    return -1;

                return Convert.ToInt32(Session["UserID"]);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Load_Wallets();
            }
        }


        protected void Load_Wallets()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
            @" SELECT a.AccountName, a.IsGmailSyncEnabled, a.IsDefault, a.Balance, i.ImagePath
            FROM Accounts a
            INNER JOIN AccountImages i on a.AccountID = i.AccountID
            WHERE a.UserID = @uID"
            , conn))
            {
                cmd.Parameters.AddWithValue("@uID", CurrentUserId);

                conn.Open();
                gV_WalletScreen.DataSource = cmd.ExecuteReader();
                gV_WalletScreen.DataBind();
            }

        }

        //========= Bound Data to GridView row ==========
        protected void gV_WallerScreen_RowDataBound(object sender, GridViewRowEventArgs e) 
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {

                bool isGmailSyncEnabled = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsGmailSyncEnabled"));

                // Get label
                Label lbl_Gmailsync = (Label)e.Row.FindControl("lbl_Gmailsync");
                LinkButton btn_Parse = (LinkButton)e.Row.FindControl("btn_Parse");

                if (isGmailSyncEnabled)
                {
                    lbl_Gmailsync.ForeColor = System.Drawing.Color.Green;
                    btn_Parse.Visible = false;
                }
                else
                {
                    lbl_Gmailsync.ForeColor = System.Drawing.Color.Red;
                    btn_Parse.Visible = true;
                }

                bool isDefault = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsDefault"));

                HtmlGenericControl span = (HtmlGenericControl)e.Row.FindControl ("DefaultText");

                if (isDefault) 
                {
                    span.Visible = true;
                }
                else 
                {
                    span.Visible = false;
                }
            }
        }

        protected void btn_Createwallet_Click(object sender, EventArgs e)
        {
            //using (SqlConnection conn = new SqlConnection(connStr))
            //using (SqlCommand cmd = new SqlCommand(
            //    @"INSERT INTO Accounts
            //    Values(@UserID, @AccountName, @AccountType, @Balance, 0,0)"), conn) 
            //{
            //    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
            //}
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