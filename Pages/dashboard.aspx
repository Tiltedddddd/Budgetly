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

                        <button class="btn-add-card">Add Card</button>
                    </div>

                    <!--Card carousells-->
                    <div class="cards-stack">

                        <div class="bank-card is-active card-blue" data-account-id="1">

                            <div class="bank-card-top">
                                <span class="bank-name">Trust</span>
                                <span class="card-type">Debit</span>
                            </div>

                            <div class="bank-card-number">
                                •••• •••• •••• 9494
                            </div>

                            <img src="../Content/images/dashboard/card-chip.png" alt="" class="card-chip" />

                            <div class="bank-card-balance">
                                <span class="card-balance-label">Balance</span>
                                <span class="card-balance-value">$12,490.19</span>
                            </div>
                        </div>

                        <div class="bank-card is-back card-green" data-account-id="2">
                            <div class="bank-card-top">
                                <span class="bank-name">Cash Account</span>
                                <span class="card-type">Cash</span>
                            </div>

                            <div class="bank-card-number">
                                •••• •••• •••• $$$$
                            </div>

                            <img src="../Content/images/dashboard/card-chip.png" alt="" class="card-chip" />

                            <div class="bank-card-balance">
                                <span class="card-balance-label">Spent</span>
                                <span class="card-balance-value">$900.00</span>
                            </div>
                        </div>

                        <div class="bank-card is-back-2 card-orange" data-account-id="3">
                            <div class="bank-card-top">
                                <span class="bank-name">POSB</span>
                                <span class="card-type">Credit</span>
                            </div>

                            <div class="bank-card-number">
                                •••• •••• •••• 1212
                            </div>

                            <img src="../Content/images/dashboard/card-chip.png" alt="" class="card-chip" />

                            <div class="bank-card-balance">
                                <span class="card-balance-label">Balance</span>
                                <span class="card-balance-value">$20.19</span>
                            </div>
                        </div>


                    </div>

                    <div class="card-pagination"></div>

                </section>

                <!-- Widget 5: Recent transactions -->
                <section class="widget widget-transactions">

                    <div class="transactions-header">
                        <h4>Recent Transactions</h4>
                        <a class="transactions-link">See All</a>
                    </div>

                    <ul class="transactions-list" id="transactionsList">
                        <!--
                        <li class="transaction-item expense">
                            <img src="../Content/images/icons/grabLogo.png" class="tx-icon" />
                            <div class="tx-info">
                                <span class="tx-merchant">Grab Transport co.</span>
                                <span class="tx-category">Transportation</span>
                            </div>
                            <span class="tx-amount negative">-$10.00</span>
                        </li>
                        -->
                    </ul>


                </section>

            </div>

            <!-- Right column -->
            <div class="dashboard-col">
                <!-- Widget 3: Expenses summary -->
                <section class="widget widget-expenses">
                    Expenses widget
                    <canvas id="expensesChart" height="130"></canvas>
                </section>


                <!-- Widget 6: Income summary -->
                <section class="widget widget-income">
                    <h4>Income</h4>
                    <canvas id="incomeChart" height="130"></canvas>
                </section>

                <!-- Widget 7: Promo / AI -->
                <section class="widget widget-promo">
                    <div class="promo-overlay"></div>

                    <div class="promo-content">
                        <h2>Start Investing Early.<br>
                            Power Your Life</h2>
                        <p>You could have saved 18% this month! Try putting $50 towards investments.</p>

                        <button class="promo-btn">Budgetly AI</button>
                    </div>
                </section>

            </div>


        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="../Scripts/dashboardPage/dashboard.js"></script>
</asp:Content>
