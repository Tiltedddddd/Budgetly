<%@ Page Title="Settings" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="settingsPage.aspx.cs" Inherits="Budgetly.Pages.settingsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="settings-container">
        <h2>Account Settings</h2>
        <hr />
        
        <div class="logout-section">
            <p>Ready to leave?</p>
            <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                CssClass="signin-btn" OnClick="btnLogout_Click" 
                OnClientClick="return confirm('Are you sure you want to log out?');" />
        </div>
    </div>
</asp:Content>