<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="signUpPage.aspx.cs" Inherits="Budgetly.Pages.signUpPage" Async="true" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Budgetly - Sign Up</title>
    <link href="../Content/css/login.css" rel="stylesheet" />
    <style>
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
<asp:Button runat="server" ID="btnGoToLogin" Text="Login" CssClass="signup-btn" 
    PostBackUrl="~/Pages/loginPage.aspx" CausesValidation="false" />            </div>
        </header>

        <img src="../Content/images/loginSignUp/loginSignUpLine.png" class="bg-line" />
        <img src="../Content/images/loginSignUp/loginSignUpGuy.png" class="bg-person" />
        <img src="../Content/images/loginSignUp/loginSignUpBlob.png" class="bg-blob" />
        <img src="../Content/images/loginSignUp/loginSignUpBar.png" class="bg-bars" />

        <main class="login-wrapper">
            <div class="login-card">
                <h2>Sign Up</h2>
                <p class="subtitle">Hey, Enter your details to create<br />your new account</p>

                <asp:TextBox runat="server" ID="txtName" CssClass="input" Placeholder="Full Name" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" 
                    ErrorMessage="Full name is required" CssClass="validation-msg" Display="Dynamic" />

                <asp:TextBox runat="server" ID="txtEmail" CssClass="input" Placeholder="Enter Email" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
                    ErrorMessage="Email is required" CssClass="validation-msg" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" 
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                    ErrorMessage="Invalid email format" CssClass="validation-msg" Display="Dynamic" />

                <asp:TextBox runat="server" ID="txtPassword" CssClass="input" TextMode="Password" Placeholder="Create Password" />
                <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" 
                    ErrorMessage="Password is required" CssClass="validation-msg" Display="Dynamic" />

                <asp:TextBox runat="server" ID="txtConfirmPassword" CssClass="input" TextMode="Password" Placeholder="Confirm Password" />
                <asp:CompareValidator ID="cvPass" runat="server" ControlToCompare="txtPassword" ControlToValidate="txtConfirmPassword" 
                    ErrorMessage="Passwords do not match" CssClass="validation-msg" Display="Dynamic" />

                <a href="loginPage.aspx" class="forgot-link">Already have an account? Log in here</a>

                <asp:Button runat="server" ID="btnSignUp" Text="Sign Up" CssClass="signin-btn" OnClick="btnSignUp_Click" />

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