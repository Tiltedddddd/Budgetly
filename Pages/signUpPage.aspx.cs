using System;
using System.Net.Http;
using System.Text;
using System.Web.UI;
using Budgetly.Models.DTOs;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace Budgetly.Pages
{
    public partial class signUpPage : Page
    {
        private static readonly HttpClient client = new HttpClient();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
            {
                Response.Redirect("dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected async void btnSignUp_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            var signUpData = new RegistrationRequestDto
            {
                FullName = txtName.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text.Trim(),
                ResetDay = 1
            };

            try
            {
                string apiUrl = Request.Url.GetLeftPart(UriPartial.Authority) + "/api/auth/signup";
                var json = JsonConvert.SerializeObject(signUpData);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                // The Page must have Async="true" for this 'await' to work
                var response = await client.PostAsync(apiUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    var resultJson = await response.Content.ReadAsStringAsync();
                    var authResponse = JsonConvert.DeserializeObject<AuthResponseDto>(resultJson);

                    if (authResponse != null)
                    {
                        Session.Clear();
                        Session["UserID"] = authResponse.UserID;
                        Session["UserName"] = signUpData.FullName;

                        // 'false' prevents the thread from being forcibly terminated
                        Response.Redirect("dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                }
                else
                {
                    ShowAlert("Registration failed. Email may already exist.");
                }
            }
            catch (System.Threading.ThreadAbortException)
            {
                // This is expected during Redirect, do nothing
            }
            catch (Exception ex)
            {
                ShowAlert("Connection error: " + ex.Message);
            }
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message}');";
            ClientScript.RegisterStartupScript(this.GetType(), "SignUpAlert", script, true);
        }
    }
}