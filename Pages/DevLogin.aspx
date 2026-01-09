<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DevLogin.aspx.cs" Inherits="Budgetly.Pages.DevLogin" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Dev User Switcher</title>
    <style>
        body { background-color: #0a1629; color: #8dc0f0; font-family: sans-serif; display: flex; justify-content: center; padding-top: 50px; }
        .card { background: #16253d; padding: 30px; border-radius: 15px; text-align: center; border: 1px solid #8dc0f0; }
        .user-link { display: block; background: #8dc0f0; color: #0a1629; padding: 10px; margin: 10px 0; text-decoration: none; border-radius: 5px; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <h2>Dev Mode: Switch User</h2>
            <p>Click a user to simulate logging in:</p>
            <asp:LinkButton ID="btnAlice" runat="server" CssClass="user-link" OnClick="SwitchUser" CommandArgument="1">Login as Alice Tan (ID: 1)</asp:LinkButton>
            <asp:LinkButton ID="btnBob" runat="server" CssClass="user-link" OnClick="SwitchUser" CommandArgument="2">Login as Bob Lim (ID: 2)</asp:LinkButton>
            <asp:LinkButton ID="btnCharlie" runat="server" CssClass="user-link" OnClick="SwitchUser" CommandArgument="3">Login as Charlie Goh (ID: 3)</asp:LinkButton>
            <asp:LinkButton ID="btnDiana" runat="server" CssClass="user-link" OnClick="SwitchUser" CommandArgument="4">Login as Diana Lee (ID: 4)</asp:LinkButton>
            <asp:LinkButton ID="btnEthan" runat="server" CssClass="user-link" OnClick="SwitchUser" CommandArgument="5">Login as Ethan Ng (ID: 5)</asp:LinkButton>
        </div>
    </form>
</body>
</html>