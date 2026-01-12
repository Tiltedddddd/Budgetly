<%@ Page Title="Transactions"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="transactionsPage.aspx.cs"
    Inherits="Budgetly.Pages.transactionsPage" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Page layout */
        .txn-wrap { padding: 24px 28px; }
        .txn-wrap.transactions-page { width: 100%; max-width: none; flex: 1; align-self: stretch; }
        .txn-title { font-size: 28px; font-weight: 650; margin: 0 0 16px 0; }

        /* Filter bar */
        .txn-bar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 14px; }
        .txn-bar-left { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .txn-bar-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }

        /* Toggle pills (All / Imported) */
        .txn-toggle { display: inline-flex; background: #eef3f8; border-radius: 999px; padding: 3px; gap: 3px; }
        .txn-toggle .txn-btn { border: 0; background: transparent; padding: 6px 12px; border-radius: 999px; cursor: pointer; font-size: 13px; }
        .txn-toggle .txn-btn.is-active { background: #ffffff; box-shadow: 0 1px 2px rgba(0,0,0,0.08); border: 1px solid #d7e2ee; }

        /* Generic buttons */
        .txn-btn { border: 1px solid #d7e2ee; background: #ffffff; padding: 7px 12px; border-radius: 10px; cursor: pointer; font-size: 13px; line-height: 1; }
        .txn-btn:hover { background: #f7fafc; }

        .txn-btn-primary { border: 0; background: #5fb4ff; color: #0b2a3d; font-weight: 600; }
        .txn-btn-primary:hover { filter: brightness(0.97); }

        /* Chips */
        .txn-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            border-radius: 999px;
            background: #5fb4ff;
            color: #0b2a3d;
            font-size: 13px;
            font-weight: 700;
        }
        .txn-chip-x {
            border: 0;
            background: rgba(255,255,255,0.55);
            color: #0b2a3d;
            font-weight: 900;
            padding: 2px 8px;
            border-radius: 999px;
            cursor: pointer;
        }
        .txn-chip-x:hover { background: rgba(255,255,255,0.75); }
        .txn-clear {
            border: 0;
            background: transparent;
            color: #2a78ff;
            font-weight: 700;
            cursor: pointer;
            padding: 6px 8px;
        }
        .txn-clear:hover { text-decoration: underline; }

        /* Dropdown */
        .txn-select { border: 1px solid #d7e2ee; background: #ffffff; padding: 6px 10px; border-radius: 10px; font-size: 13px; }

        /* Card */
        .txn-card { background: #ffffff; border: 1px solid #e6eef6; border-radius: 12px; overflow: hidden; }

        /* GridView table styling */
        .txn-table { width: 100%; border-collapse: collapse; }
        .txn-table th { text-align: left; font-size: 13px; font-weight: 700; color: #223; padding: 12px 14px; border-bottom: 1px solid #e6eef6; background: #ffffff; }
        .txn-table td { padding: 12px 14px; border-bottom: 1px solid #f0f5fa; font-size: 13px; color: #334; }
        .txn-table tr:hover td { background: #f8fbff; }

        /* Action links */
        .txn-link { border: 0; background: transparent; padding: 0; cursor: pointer; font-size: 13px; text-decoration: none; }
        .txn-link-edit { color: #2a78ff; margin-right: 10px; }
        .txn-link-del { color: #ff3b30; }

        /* Wallet badge */
        .txn-wallet { display: inline-block; padding: 5px 10px; border-radius: 8px; background: #4fb3ff; color: #ffffff; font-weight: 700; font-size: 12px; }

        /* ===== Modal ===== */
        .txn-modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.45);
            display: flex; align-items: center; justify-content: center;
            z-index: 9999;
        }
        .txn-modal {
            width: min(760px, 92vw);
            background: #fff;
            border-radius: 14px;
            border: 1px solid #e6eef6;
            box-shadow: 0 18px 50px rgba(0,0,0,0.18);
            overflow: hidden;
        }
        .txn-modal-header {
            padding: 14px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e6eef6;
            font-weight: 700;
        }
        .txn-modal-body { padding: 16px; }
        .txn-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .txn-field label { display:block; font-size: 12px; color: #445; margin: 0 0 6px 0; font-weight: 700; }
        .txn-input {
            width: 100%;
            border: 1px solid #d7e2ee;
            border-radius: 10px;
            padding: 9px 10px;
            font-size: 13px;
            outline: none;
        }
        .txn-input:focus { border-color: #5fb4ff; box-shadow: 0 0 0 3px rgba(95,180,255,0.22); }
        .txn-modal-footer {
            padding: 14px 16px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            border-top: 1px solid #e6eef6;
            background: #fbfdff;
        }
        .txn-error { margin-top: 10px; color: #b42318; font-size: 13px; font-weight: 600; }
        @media (max-width: 700px){ .txn-form-grid { grid-template-columns: 1fr; } }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="txn-wrap transactions-page">
        <div class="txn-title">Transactions</div>

        <div class="txn-bar">
            <div class="txn-bar-left">

                <div class="txn-toggle">
                    <asp:Button ID="btnAll" runat="server" Text="All" CssClass="txn-btn is-active" OnClick="btnAll_Click" />
                    <asp:Button ID="btnImported" runat="server" Text="Imported" CssClass="txn-btn" OnClick="btnImported_Click" />
                </div>

                <asp:Button ID="btnFilters" runat="server" Text="Filters" CssClass="txn-btn" OnClick="btnFilters_Click" />

                <!-- Dynamic filter chips -->
                <asp:Repeater ID="rptActiveFilters" runat="server" OnItemCommand="rptActiveFilters_ItemCommand">
                    <ItemTemplate>
                        <span class="txn-chip">
                            <%# Eval("Text") %>
                            <asp:LinkButton
                                ID="btnRemoveChip"
                                runat="server"
                                CssClass="txn-chip-x"
                                Text="✕"
                                CommandName="Remove"
                                CommandArgument='<%# Eval("Key") %>' />
                        </span>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:LinkButton ID="btnClearAllFilters" runat="server" CssClass="txn-clear" OnClick="btnClearAllFilters_Click" Visible="false">
                    Clear all
                </asp:LinkButton>

            </div>

            <div class="txn-bar-right">
                <asp:Button ID="btnManualAdd" runat="server" Text="+ Manual Add" CssClass="txn-btn txn-btn-primary" OnClick="btnManualAdd_Click" />

                <asp:DropDownList ID="ddlMonth" runat="server" CssClass="txn-select" AutoPostBack="true" OnSelectedIndexChanged="ddlMonth_SelectedIndexChanged">
                    <asp:ListItem Text="Jan" Value="1" />
                    <asp:ListItem Text="Feb" Value="2" />
                    <asp:ListItem Text="Mar" Value="3" />
                    <asp:ListItem Text="Apr" Value="4" />
                    <asp:ListItem Text="May" Value="5" />
                    <asp:ListItem Text="Jun" Value="6" />
                    <asp:ListItem Text="Jul" Value="7" />
                    <asp:ListItem Text="Aug" Value="8" />
                    <asp:ListItem Text="Sep" Value="9" />
                    <asp:ListItem Text="Oct" Value="10" />
                    <asp:ListItem Text="Nov" Value="11" />
                    <asp:ListItem Text="Dec" Value="12" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="txn-card">
            <asp:GridView ID="gvTransactions"
                runat="server"
                CssClass="txn-table"
                AutoGenerateColumns="False"
                DataKeyNames="TransactionID"
                OnRowCommand="gvTransactions_RowCommand">

                <Columns>
                    <asp:BoundField DataField="Category" HeaderText="Category" />
                    <asp:BoundField DataField="Merchant" HeaderText="Merchant" />
                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="${0:N2}" />
                    <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:dd/MM/yyyy}" />

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEdit"
                                runat="server"
                                Text="Edit"
                                CssClass="txn-link txn-link-edit"
                                CommandName="EditTxn"
                                CommandArgument='<%# Eval("TransactionID") %>' />

                            <asp:LinkButton ID="btnDelete"
                                runat="server"
                                Text="Delete"
                                CssClass="txn-link txn-link-del"
                                CommandName="DeleteTxn"
                                CommandArgument='<%# Eval("TransactionID") %>'
                                OnClientClick="return confirm('Delete this transaction?');" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Wallet">
                        <ItemTemplate>
                            <span class="txn-wallet"><%# Eval("Wallet") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>

            </asp:GridView>
        </div>
    </div>

    <!-- ===== Filters Modal ===== -->
    <asp:Panel ID="pnlFiltersOverlay" runat="server" Visible="false" CssClass="txn-modal-overlay">
        <div class="txn-modal">
            <div class="txn-modal-header">
                <asp:Label ID="lblFiltersTitle" runat="server" Text="Filters" />
                <asp:Button ID="btnFiltersClose" runat="server" Text="✕" CssClass="txn-btn" OnClick="btnFiltersCancel_Click" />
            </div>

            <div class="txn-modal-body">
                <div class="txn-form-grid">
                    <div class="txn-field">
                        <label>Wallet</label>
                        <asp:DropDownList ID="ddlFilterWallet" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Category</label>
                        <asp:DropDownList ID="ddlFilterCategory" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Merchant (contains)</label>
                        <asp:TextBox ID="txtFilterMerchant" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Amount min</label>
                        <asp:TextBox ID="txtAmountMin" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Amount max</label>
                        <asp:TextBox ID="txtAmountMax" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Date from</label>
                        <asp:TextBox ID="txtDateFrom" runat="server" CssClass="txn-input" TextMode="Date" />
                    </div>

                    <div class="txn-field">
                        <label>Date to</label>
                        <asp:TextBox ID="txtDateTo" runat="server" CssClass="txn-input" TextMode="Date" />
                    </div>
                </div>

                <asp:Label ID="lblFiltersError" runat="server" CssClass="txn-error" Visible="false" />
            </div>

            <div class="txn-modal-footer">
                <asp:Button ID="btnFiltersReset" runat="server" Text="Reset" CssClass="txn-btn" OnClick="btnFiltersReset_Click" />
                <asp:Button ID="btnFiltersCancel" runat="server" Text="Cancel" CssClass="txn-btn" OnClick="btnFiltersCancel_Click" />
                <asp:Button ID="btnFiltersApply" runat="server" Text="Apply" CssClass="txn-btn txn-btn-primary" OnClick="btnFiltersApply_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- ===== Edit/Add Modal ===== -->
    <asp:Panel ID="pnlModalOverlay" runat="server" Visible="false" CssClass="txn-modal-overlay">
        <div class="txn-modal">
            <div class="txn-modal-header">
                <asp:Label ID="lblModalTitle" runat="server" Text="Edit Transaction" />
                <asp:Button ID="btnModalClose" runat="server" Text="✕" CssClass="txn-btn" OnClick="btnModalCancel_Click" />
            </div>

            <div class="txn-modal-body">
                <asp:HiddenField ID="hfMode" runat="server" />
                <asp:HiddenField ID="hfTransactionId" runat="server" />

                <div class="txn-form-grid">
                    <div class="txn-field">
                        <label>Wallet</label>
                        <asp:DropDownList ID="ddlEditWallet" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Category</label>
                        <asp:DropDownList ID="ddlEditCategory" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Merchant</label>
                        <asp:TextBox ID="txtMerchant" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Amount</label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="txn-input" />
                    </div>

                    <div class="txn-field">
                        <label>Date</label>
                        <asp:TextBox ID="txtDate" runat="server" CssClass="txn-input" TextMode="Date" />
                    </div>

                    <div class="txn-field">
                        <label>Type</label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="txn-input">
                            <asp:ListItem Text="EXPENSE" Value="EXPENSE" />
                            <asp:ListItem Text="INCOME" Value="INCOME" />
                        </asp:DropDownList>
                    </div>

                    <div class="txn-field" style="grid-column: 1 / -1;">
                        <label>Description (optional)</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="txn-input" />
                    </div>
                </div>

                <asp:Label ID="lblModalError" runat="server" CssClass="txn-error" Visible="false" />
            </div>

            <div class="txn-modal-footer">
                <asp:Button ID="btnModalCancel" runat="server" Text="Cancel" CssClass="txn-btn" OnClick="btnModalCancel_Click" />
                <asp:Button ID="btnModalSave" runat="server" Text="Save" CssClass="txn-btn txn-btn-primary" OnClick="btnModalSave_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>


