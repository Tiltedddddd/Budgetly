<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="loginPage.aspx.cs" Inherits="Budgetly.Pages.loginPage" Async="true" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Budgetly - Login</title>
    <link href="../Content/css/login.css" rel="stylesheet" />
    <style>
        /* Internal style to ensure validation messages don't break the layout */
        .validation-msg {
            color: #ff4d4d;
            font-size: 12px;
            display: block;
            text-align: left;
            margin: -10px 0 10px 5px;
        }
    </style>
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
<asp:Button runat="server" ID="btnTopSignUp" Text="Sign up" CssClass="signup-btn" PostBackUrl="~/Pages/signUpPage.aspx" CausesValidation="false"/>            </div>
        </header>

        <img src="../Content/images/loginSignUp/loginSignUpLine.png" class="bg-line" />
        <img src="../Content/images/loginSignUp/loginSignUpGuy.png" class="bg-person" />
        <img src="../Content/images/loginSignUp/loginSignUpBlob.png" class="bg-blob" />
        <img src="../Content/images/loginSignUp/loginSignUpBar.png" class="bg-bars" />

        <main class="login-wrapper">
            <div class="login-card">
                <h2>Login</h2>
                <p class="subtitle">Hey, Enter your account details to<br />access your account</p>

                <asp:TextBox ID="txtEmail" runat="server" CssClass="input" Placeholder="Enter Email" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
                    ErrorMessage="Email is required" CssClass="validation-msg" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" 
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                    ErrorMessage="Invalid email format" CssClass="validation-msg" Display="Dynamic" />

                <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" Placeholder="Password" />
                <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" 
                    ErrorMessage="Password is required" CssClass="validation-msg" Display="Dynamic" />

                <a href="#" class="forgot-link">Trouble with signing in? Click here</a>

                <asp:Button ID="btnLogin" runat="server" Text="Sign in" CssClass="signin-btn" OnClick="btnLogin_Click" />

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