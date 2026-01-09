<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="Budgetly.Pages.homePage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="../Content/css/dashboard.css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-dashboard">

        <div class="dashboard-grid">

             <!-- Widget 1: Pet / Gamification -->
            <section class="widget widget-pet">
                Pet widget
            </section>

            <!-- Widget 2: Cards -->
            <section class="widget widget-cards">
                Cards widget
            </section>

            <!-- Widget 3: Expenses summary -->
            <section class="widget widget-expenses">
                Expenses widget
            </section>

            <!-- Widget 4: Friends leaderboard -->
            <section class="widget widget-leaderboard">
                Leaderboard widget
            </section>

            <!-- Widget 5: Recent transactions -->
            <section class="widget widget-transactions">
                Transactions widget
            </section>

            <!-- Widget 6: Income summary -->
            <section class="widget widget-income">
                Income widget
            </section>

            <!-- Widget 7: Promo / AI -->
            <section class="widget widget-promo">
                Promo widget
            </section>


        </div>
    </div>
</asp:Content>
