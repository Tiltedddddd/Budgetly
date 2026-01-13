using System;
using System.Net.Http;
using System.Text;
using System.Web.UI;
using Budgetly.Models.DTOs;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace Budgetly.Pages
{
    public partial class loginPage : Page
    {
        private static readonly HttpClient client = new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
            // If Session already exists, don't show login
            if (Session["UserID"] != null)
            {
                Response.Redirect("dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected async void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            var loginData = new LoginRequestDto
            {
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text.Trim()
            };

            try
            {
                string apiUrl = Request.Url.GetLeftPart(UriPartial.Authority) + "/api/auth/login";
                var json = JsonConvert.SerializeObject(loginData);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await client.PostAsync(apiUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    var resultJson = await response.Content.ReadAsStringAsync();
                    var authResponse = JsonConvert.DeserializeObject<AuthResponseDto>(resultJson);

                    if (authResponse != null && authResponse.Success)
                    {
                        // IMPORTANT: Clear any old session data before setting new
                        Session.Clear();

                        // Set Session variables
                        Session["UserID"] = authResponse.UserID;
                        Session["UserName"] = authResponse.FullName;

                        // Use false for endResponse to prevent ThreadAbortException in Async
                        Response.Redirect("dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        ShowAlert("Invalid email or password.");
                    }
                }
                else
                {
                    ShowAlert("Login failed. Please check your credentials.");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error connecting to server.");
            }
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message}');";
            ClientScript.RegisterStartupScript(this.GetType(), "LoginAlert", script, true);
        }
    }
}