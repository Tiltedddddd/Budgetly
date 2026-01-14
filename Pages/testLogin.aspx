<%@ Page Title="Test Login" MasterPageFile="~/Site.Master" Language="C#" AutoEventWireup="true" CodeBehind="testLogin.aspx.cs" Inherits="Budgetly.Pages.testLogin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        body { font-family: Arial, sans-serif; background: #f9fafb; display:flex; justify-content:center; align-items:center; height:100vh; margin:0; }
        .login-card { background:white; padding:30px; border-radius:10px; box-shadow:0 2px 10px rgba(0,0,0,0.1); width:350px; text-align:center; }
        h2 { margin-bottom:20px; }
        .user-btn { display:block; width:100%; margin:10px 0; padding:10px; border:none; border-radius:5px; font-size:16px; cursor:pointer; background:#3b82f6; color:white; transition:0.2s; }
        .user-btn:hover { background:#2563eb; }
    </style>

    <div class="login-card">
        <h2>Pick a Test User</h2>
        <asp:Button ID="btnUser1" runat="server" Text="Alice Tan" CssClass="user-btn" OnClick="User_Click" CommandArgument="1" />
        <asp:Button ID="btnUser2" runat="server" Text="Bob Lim" CssClass="user-btn" OnClick="User_Click" CommandArgument="2" />
        <asp:Button ID="btnUser3" runat="server" Text="Charlie Goh" CssClass="user-btn" OnClick="User_Click" CommandArgument="3" />
        <asp:Button ID="btnUser4" runat="server" Text="Diana Lee" CssClass="user-btn" OnClick="User_Click" CommandArgument="4" />
        <asp:Button ID="btnUser5" runat="server" Text="Ethan Ng" CssClass="user-btn" OnClick="User_Click" CommandArgument="5" />
    </div>
</asp:Content>
