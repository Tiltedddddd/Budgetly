<%@ Page Title="Your Wallets" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="walletsPage.aspx.cs" Inherits="Budgetly.Pages.walletsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link runat="server" href="~/Content/css/walletsPage.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="wallets-shell">
        <div class="wallets-stage">
            <div class="wallets-title">Your Wallets</div>

            <div class="wallets-card">

                <asp:Label ID="lblError" runat="server" CssClass="danger" Visible="false" />

                <asp:Repeater ID="rptWallets" runat="server" OnItemCommand="rptWallets_ItemCommand">
                    <ItemTemplate>
                        <div class="wallet-row">
                            <!-- LEFT -->
                            <div class="wallet-left">
                                <div class="wallet-name"><%# Eval("AccountName") %></div>

                                <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("IsCash") %>'>
    <div class="wallet-subline">
        <span>Email Sync</span>
        <span class='sync-dot <%# (bool)Eval("IsGmailSyncEnabled") ? "dot-green" : "dot-red" %>'></span>
    </div>

    <asp:HyperLink ID="lnkSetupParsing" runat="server"
        CssClass="wallet-setup-link"
        NavigateUrl="~/Pages/settingsPage.aspx"
        Text="Set up parsing!"
        Visible='<%# !(bool)Eval("IsGmailSyncEnabled") %>' />
</asp:PlaceHolder>

                                <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsCash") %>'>
                                    <div class="wallet-subline">Cash - Manual</div>
                                </asp:PlaceHolder>

                                <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("IsDefault") %>'>
                                    <div class="wallet-default-text">Default</div>
                                </asp:PlaceHolder>
                            </div>

                            <!-- MID -->
                            <div class="wallet-mid">
                                $<%# Eval("Balance", "{0:N2}") %>
                            </div>

                            <!-- ACTIONS -->
                            <div class="wallet-actions">
                                <a class="wallet-link" href='/Pages/transactionsPage.aspx?accountId=<%# Eval("AccountID") %>'>View Transactions</a>
                                <span class="action-sep">|</span>

                                <asp:LinkButton runat="server" CssClass="action-btn"
                                    CommandName="Edit"
                                    CommandArgument='<%# Eval("AccountID") %>'
                                    CausesValidation="false"
                                    Text="Edit" />

                                <span class="action-sep">|</span>

                                <asp:LinkButton runat="server" CssClass="action-btn"
                                    CommandName="Remove"
                                    CommandArgument='<%# Eval("AccountID") %>'
                                    CausesValidation="false"
                                    OnClientClick="return confirm('Remove this wallet?');"
                                    Text="Remove" />

                                <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("IsDefault") %>'>
                                    <span class="action-sep">|</span>
                                    <asp:LinkButton runat="server" CssClass="action-btn"
                                        CommandName="Default"
                                        CommandArgument='<%# Eval("AccountID") %>'
                                        CausesValidation="false"
                                        Text="Set as default" />
                                </asp:PlaceHolder>
                            </div>

                            <!-- BADGE -->
                            <div class='wallet-badge <%# Eval("BadgeCss") %>'>
                                <%# Eval("BadgeText") %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <div class="wallet-add-wrap">
                    <asp:Button ID="btnShowAdd" runat="server" CssClass="btn-add" Text="+ Add Card"
                        OnClick="btnShowAdd_Click" CausesValidation="false" />
                </div>

            </div>
        </div>
    </div>

    <!-- MODAL -->
    <asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="modal-mask">
        <div class="modal-box">
            <div class="modal-title">
                <asp:Label ID="lblModalTitle" runat="server" Text="Add Card" />
            </div>

            <asp:HiddenField ID="hfEditingAccountID" runat="server" />

            <div class="form-grid">
                <div>
                    <label class="form-label">Account Name</label>
                    <asp:TextBox ID="txtAccountName" runat="server" CssClass="form-input" MaxLength="50" />
                </div>

                <div>
                    <label class="form-label">Account Balance ($)</label>
                    <asp:TextBox ID="txtBalance" runat="server" CssClass="form-input" />
                </div>

                <div>
                    <label class="form-label">Account Type</label>
                    <asp:DropDownList ID="ddlAccountType" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Savings" Value="Savings" />
                        <asp:ListItem Text="Credit" Value="Credit" />
                        <asp:ListItem Text="Cash" Value="Cash" />
                        <asp:ListItem Text="Digital" Value="Digital" />
                    </asp:DropDownList>
                </div>

                <div class="chk-row">
                    <asp:CheckBox ID="chkGmailSync" runat="server" />
                    <span class="chk-text">Enable Gmail Sync</span>
                </div>

                <asp:Label ID="lblModalError" runat="server" CssClass="danger" Visible="false" />
            </div>

            <div class="modal-actions">
                <asp:Button ID="btnCancel" runat="server" CssClass="btn-secondary" Text="Cancel"
                    OnClick="btnCancel_Click" CausesValidation="false" />
                <asp:Button ID="btnSave" runat="server" CssClass="btn-primary" Text="Save"
                    OnClick="btnSave_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>
