<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="loginPage.aspx.cs" Inherits="Budgetly.Pages.loginPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Budgetly</title>
    <link href="../Content/css/login.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- ===== Header ===== -->
        <header class="login-header">
            <div class="header-left">
                <span class="budgetly-name">Budgetly</span>
                <span class="budgetly-divider"></span>
                <span class="budgetly-email">budgetly@email.com</span>
            </div>

            <div class="header-right">
                <span class="lang-icon">🌐</span>
                <asp:Button runat="server" Text="Sign up" Class="signup-btn" />
            </div>
        </header>git 

        <!-- ===== Decorative Background Images ===== -->
        <img src="../Content/images/loginSignUp/loginSignUpLine.png" class="bg-line" />
        <img src="../Content/images/loginSignUp/loginSignUpGuy.png" class="bg-person" />
        <img src="../Content/images/loginSignUp/loginSignUpBlob.png" class="bg-blob" />
        <img src="../Content/images/loginSignUp/loginSignUpBar.png" class="bg-bars" />
        <!-- ===== Center Login Card ===== -->
        <main class="login-wrapper">
            <div class="login-card">

                <h2>Login</h2>
                <p class="subtitle">
                    Hey, Enter your account details to<br />
                    access your account
                </p>

                <asp:TextBox
                    runat="server"
                    CssClass="input"
                    Placeholder="Enter Email / Phone No" />

                <asp:TextBox
                    runat="server"
                    CssClass="input"
                    TextMode="Password"
                    Placeholder="Password" />

                <a href="#" class="forgot-link">Trouble with signing in? Click here</a>

                <asp:Button
                    runat="server"
                    Text="Sign in"
                    CssClass="signin-btn" />

                <div class="divider">
                    <span>Or Sign In with</span>
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
