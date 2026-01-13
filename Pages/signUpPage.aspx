<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="signUpPage.aspx.cs" Inherits="Budgetly.Pages.signUpPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Budgetly - Sign Up</title>
    <link href="../Content/css/login.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <header class="login-header">
            <div class="header-left">
                <span class="budgetly-name">Budgetly</span>
                <span class="budgetly-divider"></span>
                <span class="budgetly-email">budgetly@email.com</span>
            </div>

            <div class="header-right">
                <span class="lang-icon">🌐</span>
                <asp:Button runat="server" Text="Sign In" ID="btnGoToLogin" Class="signup-btn" PostBackUrl="~/Pages/loginPage.aspx" />
            </div>
        </header>

        <img src="../Content/images/loginSignUp/loginSignUpLine.png" class="bg-line" />
        <img src="../Content/images/loginSignUp/loginSignUpGuy.png" class="bg-person" />
        <img src="../Content/images/loginSignUp/loginSignUpBlob.png" class="bg-blob" />
        <img src="../Content/images/loginSignUp/loginSignUpBar.png" class="bg-bars" />

        <main class="login-wrapper">
            <div class="login-card">

                <h2>Sign Up</h2>
                <p class="subtitle">
                    Hey, Enter your details to create<br />
                    your new account
                </p>

                <asp:TextBox 
                    runat="server" 
                    ID="txtName"
                    CssClass="input" 
                    Placeholder="Full Name" />

                <asp:TextBox 
                    runat="server" 
                    ID="txtEmail"
                    CssClass="input" 
                    Placeholder="Enter Email / Phone No" />

                <asp:TextBox 
                    runat="server" 
                    ID="txtPassword"
                    CssClass="input" 
                    TextMode="Password" 
                    Placeholder="Create Password" />

                <a href="#" class="forgot-link">Already have an account? Sign in here</a>

                <asp:Button 
                    runat="server" 
                    ID="btnSignUp"
                    Text="Sign Up" 
                    CssClass="signin-btn" />

                <div class="divider">
                    <span>Or Sign Up with</span>
                </div>

                <div class="social-buttons">
                    <button type="button">Apple</button>
                    <button type="button">Google</button>
                    <button type="button">Facebook</button>
                </div>

            </div>
        </main>

    </form>
</body>
</html>