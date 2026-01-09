<%@ Page Title="Goal Setting" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="goalSettingPage.aspx.cs" Inherits="Budgetly.Pages.goalSettingPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link href="../Content/css/goalSettingPage.css" rel="stylesheet" />

    <div class="goal-card">
        <div id="notificationZone">
            <asp:Label ID="lblStatus" runat="server" Visible="false"></asp:Label>
        </div>

        <div class="income-section">
            <p class="income-label">Monthly income: <span class="income-amount"><asp:Literal ID="litIncomeSub" runat="server" /></span></p>
        </div>

        <div class="budget-table-container">
            <table class="budget-table">
                <tbody>
                    <asp:Repeater ID="rptBudgetEnvelopes" runat="server" OnItemCommand="rptBudgetEnvelopes_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="col-category"><%# Eval("CategoryName") %></td>
                                <td class="col-amount">
                                    <asp:PlaceHolder runat="server" Visible='<%# (int)Eval("EnvelopeID") != EditingID %>'>
                                        $<%# Eval("MonthlyLimit", "{0:N2}") %>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# (int)Eval("EnvelopeID") == EditingID %>'>
                                        <asp:TextBox ID="txtInlineAmount" runat="server" Text='<%# Eval("MonthlyLimit") %>' CssClass="form-input" TextMode="Number" step="0.01"></asp:TextBox>
                                    </asp:PlaceHolder>
                                </td>
                                <td class="col-actions">
                                    <asp:PlaceHolder runat="server" Visible='<%# (int)Eval("EnvelopeID") != EditingID %>'>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="StartEdit" CommandArgument='<%# Eval("EnvelopeID") %>' CssClass="action-link blue">Edit</asp:LinkButton>
                                        <span class="sep">|</span>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteCategory" CommandArgument='<%# Eval("EnvelopeID") %>' CssClass="action-link red" OnClientClick="return confirm('Delete?');">Delete</asp:LinkButton>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# (int)Eval("EnvelopeID") == EditingID %>'>
                                        <asp:LinkButton ID="btnSave" runat="server" CommandName="SaveEdit" CommandArgument='<%# Eval("EnvelopeID") %>' CssClass="action-link blue">Save</asp:LinkButton>
                                        <span class="sep">|</span>
                                        <asp:LinkButton ID="btnCancel" runat="server" CommandName="CancelEdit" CssClass="action-link muted">Cancel</asp:LinkButton>
                                    </asp:PlaceHolder>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>

            <div class="month-selector-wrapper">
                <asp:LinkButton ID="btnPrevMonth" runat="server" OnClick="ChangeMonth_Click" CommandArgument="-1" CssClass="nav-arrow">&lt;</asp:LinkButton>
                <asp:LinkButton ID="btnShowPicker" runat="server" OnClick="TogglePicker_Click" CssClass="current-month-display">
                    <asp:Literal ID="litCurrentMonth" runat="server" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnNextMonth" runat="server" OnClick="ChangeMonth_Click" CommandArgument="1" CssClass="nav-arrow">&gt;</asp:LinkButton>
            </div>

            <asp:Panel ID="pnlPicker" runat="server" Visible="false" CssClass="picker-dropdown">
                <asp:MultiView ID="mvPicker" runat="server">
                    <asp:View runat="server">
                        <div class="picker-header">
                            <asp:LinkButton ID="btnSwitchToYear" runat="server" OnClick="btnSwitchToYear_Click"><asp:Literal ID="litPickerYear" runat="server" /></asp:LinkButton>
                            <asp:LinkButton runat="server" OnClick="btnToday_Click" CssClass="action-link blue">Today</asp:LinkButton>
                        </div>
                        <div class="picker-grid">
                            <asp:Repeater ID="rptMonths" runat="server" OnItemCommand="rptMonths_ItemCommand">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandArgument='<%# Eval("MonthNum") %>' CssClass='<%# Eval("CssClass") %>'><%# Eval("MonthName") %></asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:View>
                    <asp:View runat="server">
                         <div class="picker-header">
                            <asp:LinkButton runat="server" OnClick="ChangeDecade_Click" CommandArgument="-10">&laquo;</asp:LinkButton>
                            <asp:Literal ID="litDecadeRange" runat="server" />
                            <asp:LinkButton runat="server" OnClick="ChangeDecade_Click" CommandArgument="10">&raquo;</asp:LinkButton>
                        </div>
                        <div class="picker-grid">
                            <asp:Repeater ID="rptYears" runat="server" OnItemCommand="rptYears_ItemCommand">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandArgument='<%# Container.DataItem %>' CssClass="grid-item"><%# Container.DataItem %></asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:View>
                </asp:MultiView>
            </asp:Panel>
        </div>

        <div class="budget-summary">
            Total budgeted: <strong>$<asp:Literal ID="litTotalBudgeted" runat="server" /></strong> 
            | Remaining: <strong>$<asp:Literal ID="litRemaining" runat="server" /></strong>
        </div>

        <div class="add-action-area">
            <button type="button" id="mainAddBtn" class="btn-add-toggle" onclick="toggleAddForm(true)">+ Add Category</button>
            
            <div id="addForm" class="add-form-panel" style="display:none;">
                <asp:DropDownList ID="ddlCategories" runat="server" CssClass="form-select custom-dropdown"></asp:DropDownList>
                <asp:TextBox ID="txtAmount" runat="server" placeholder="Amount" CssClass="form-input" TextMode="Number" step="0.01"></asp:TextBox>
                
                <div class="form-actions">
                    <asp:Button ID="btnSubmitAdd" runat="server" Text="Confirm" OnClick="btnAddCategory_Click" CssClass="btn-add-toggle" />
                    <button type="button" class="cancel-btn" onclick="toggleAddForm(false)">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Run hideNotification immediately on page load to handle postbacks
        window.onload = hideNotification;

        function toggleAddForm(show) {
            var form = document.getElementById('addForm');
            var btn = document.getElementById('mainAddBtn');
            if (show) {
                form.style.display = 'flex';
                btn.style.display = 'none';
            } else {
                form.style.display = 'none';
                btn.style.display = 'block';
            }
        }

  
    // This ensures it runs after every click (Add, Save, or Delete)
            document.addEventListener("DOMContentLoaded", function() {                hideNotification();
    });

            function hideNotification() {
        var label = document.getElementById('<%= lblStatus.ClientID %>');
         if (label && label.innerText.trim() !== "") {
             // Reset opacity in case it was hidden previously
             label.style.opacity = '1';
         label.style.display = 'block';

         setTimeout(function () {
             label.style.transition = "opacity 0.5s ease";
         label.style.opacity = '0';
         setTimeout(function () {label.style.display = 'none'; }, 500);
            }, 3000); 
        }
    }

    </script>
</asp:Content>