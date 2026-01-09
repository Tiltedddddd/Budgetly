<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="Budgetly.Pages.homePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="../Content/css/dashboard.css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-dashboard">

        <div class="dashboard-grid">

            <!-- Left column -->
            <div class="dashboard-col">
                <section class="widget widget-pet">
                    Pet widget
                </section>

                <section class="widget widget-leaderboard">
                    Leaderboard widget
                </section>
            </div>


            <!-- Center column -->
            <div class="dashboard-col">
                <section class="widget widget-accounts">
                    <!-- Header -->
                    <div class="card-header">
                        <div>
                            <h3 class="cards-title">My Cards</h3>
                            <p class="cards-subtitle">Add different cards to categorize!</p>
                        </div>

                        <button class="btn btn-light"></button>
                    </div>

                    <!--Card carousells-->
                    <div class="cards-carousel">

                        <div class="bank-card is-active">

                            <div class="bank-card-top">
                                <span class="bank-name">Trust</span>
                                <span class="card-type">Debit</span>
                            </div>

                            <div class="bank-card-number">
                                •••• •••• •••• 9494
                            </div>

                            <div class="bank-card-footer">
                                <span class="card-holder">DARREN KEE</span>
                                <span class="card-balance">$12,490.19</span>
                            </div>
                        </div>

                    </div>
                </section>

                <!-- Widget 5: Recent transactions -->
                <section class="widget widget-transactions">
                    Transactions widget
                </section>

            </div>

            <!-- Right column -->
            <div class="dashboard-col">
                <!-- Widget 3: Expenses summary -->
                <section class="widget widget-expenses">
                    Expenses widget
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
    </div>
</asp:Content>
