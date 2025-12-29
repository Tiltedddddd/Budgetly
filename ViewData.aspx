<%@ Page Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="ViewData.aspx.cs"
    Inherits="Budgetly.ViewData" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="ContentPlaceHolder1"
    runat="server">

    <style>
        .grid-container {
            margin-bottom: 30px;
            border: 1px solid #ddd;
            padding: 10px;
            border-radius: 5px;
        }
        h2 {
            color: #333;
            margin-top: 25px;
            padding-bottom: 5px;
            border-bottom: 2px solid #007bff;
        }
    </style>

    <div class="container">
        <h1>Database Viewer - All Tables</h1>

        <div class="grid-container">
            <h2>Users</h2>
            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>UserProfiles</h2>
            <asp:GridView ID="gvUserProfiles" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Subscriptions</h2>
            <asp:GridView ID="gvSubscriptions" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>UserSubscriptions</h2>
            <asp:GridView ID="gvUserSubscriptions" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Accounts</h2>
            <asp:GridView ID="gvAccounts" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>AccountImages</h2>
            <asp:GridView ID="gvAccountImages" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Categories</h2>
            <asp:GridView ID="gvCategories" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Transactions</h2>
            <asp:GridView ID="gvTransactions" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>TransactionAttachments</h2>
            <asp:GridView ID="gvTransactionAttachments" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>GmailTransactionTracker</h2>
            <asp:GridView ID="gvGmailTransactionTracker" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Income</h2>
            <asp:GridView ID="gvIncome" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Budgets</h2>
            <asp:GridView ID="gvBudgets" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>BudgetEnvelopes</h2>
            <asp:GridView ID="gvBudgetEnvelopes" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>BudgetProgress</h2>
            <asp:GridView ID="gvBudgetProgress" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Pets</h2>
            <asp:GridView ID="gvPets" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>UserPets</h2>
            <asp:GridView ID="gvUserPets" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>PetStatusImages</h2>
            <asp:GridView ID="gvPetStatusImages" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Badges</h2>
            <asp:GridView ID="gvBadges" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>UserBadges</h2>
            <asp:GridView ID="gvUserBadges" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>Challenges</h2>
            <asp:GridView ID="gvChallenges" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>UserChallenges</h2>
            <asp:GridView ID="gvUserChallenges" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>LeaderboardStats</h2>
            <asp:GridView ID="gvLeaderboardStats" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>EcoScores</h2>
            <asp:GridView ID="gvEcoScores" runat="server" AutoGenerateColumns="true" />
        </div>

        <div class="grid-container">
            <h2>MerchantRules</h2>
            <asp:GridView ID="gvMerchantRules" runat="server" AutoGenerateColumns="true" />
        </div>

    </div>

</asp:Content>
