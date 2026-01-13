<%@ Page Title="Goal Setting" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="goalSettingPage.aspx.cs" Inherits="Budgetly.Pages.goalSettingPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link href="../Content/css/goalSettingPage.css" rel="stylesheet" />

<div id="notificationZone">
    <div id="customToast" class="planner-toast" style="display:none;">
        <span id="toastIcon">✅</span> 
        <asp:Label ID="lblStatus" runat="server" CssClass="status-message"></asp:Label>
    </div>
</div>
    <div class="goal-card">
        <div class="income-section" style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
                <p class="income-label">Monthly Income: <span class="income-amount">$<asp:Literal ID="litIncomeSub" runat="server" /></span></p>
                <p class="income-label">Monthly Budget Limit: <span class="income-amount">$<asp:Literal ID="litBudgetAmount" runat="server" /></span></p>
            </div>
            
            <div class="planner-inline-trigger">
                <button type="button" class="btn-bell-inline" onclick="togglePlanner()">
                    <span>Budget Forecast</span>
                </button>
            </div>
        </div>

        <asp:Panel ID="pnlBudgetWarning" runat="server" CssClass="budget-warning-alert" Visible="false">
            <strong>Warning:</strong> You have exceeded your budget by $<asp:Literal ID="litOverAmount" runat="server" />!
        </asp:Panel>

        <div class="workflow-actions" style="margin-bottom:15px;">
            <asp:LinkButton ID="btnCopyLastMonth" runat="server" OnClick="btnCopyLastMonth_Click" CssClass="btn-template">
                Copy Last Month's Goals
            </asp:LinkButton>
        </div>

        <div class="main-layout-wrapper">
            <div class="budget-table-container">
                <table class="budget-table">
                    <thead>
                        <tr>
                            <th class="col-category">Category</th>
                            <th class="col-amount">Monthly Limit</th>
                            <th class="col-health">Usage Health</th> 
                            <th class="col-amount">Remaining</th>
                            <th class="col-actions">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="budgetTableBody">
                        <asp:Repeater ID="rptBudgetEnvelopes" runat="server" OnItemCommand="rptBudgetEnvelopes_ItemCommand">
                            <ItemTemplate>
                                <tr data-catid='<%# Eval("CategoryID") %>' data-current='<%# Eval("MonthlyLimit") %>'>
                                    <td class="col-category"><%# Eval("CategoryName") %></td>
                                    <td class="col-amount">
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) != EditingID %>'>
                                            $<%# Eval("MonthlyLimit", "{0:N2}") %>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) == EditingID %>'>
                                            <asp:TextBox ID="txtInlineAmount" runat="server" Text='<%# Eval("MonthlyLimit") %>' CssClass="form-input" TextMode="Number" step="0.01"></asp:TextBox>
                                        </asp:PlaceHolder>
                                    </td>
                                    <td class="col-health">
                                        <div class="progress-track">
                                            <div class='<%# "progress-fill " + GetHealthClass(Eval("SpentAmount"), Eval("MonthlyLimit")) %>' style='<%# string.Format("width: {0}%;", GetProgressWidth(Eval("SpentAmount"), Eval("MonthlyLimit"))) %>'>
                                            </div>
                                        </div>
                                        <small class="progress-subtext" style="font-weight: 400;">$<%# Eval("SpentAmount", "{0:N0}") %> spent</small>
                                    </td>
                                    <td class="col-amount">
                                        <strong>$<%# (Convert.ToDecimal(Eval("MonthlyLimit")) - Convert.ToDecimal(Eval("SpentAmount"))).ToString("N2") %></strong>
                                    </td>
                                    <td class="col-actions" style="text-align: center;">
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) != EditingID %>'>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="StartEdit" CommandArgument='<%# Eval("EnvelopeID") %>' CssClass="action-link blue">Edit</asp:LinkButton>
                                            <span class="sep">|</span>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteCategory" CommandArgument='<%# Eval("EnvelopeID") %>' CssClass="action-link red" OnClientClick="return confirm('Delete this category?');">Delete</asp:LinkButton>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) == EditingID %>'>
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

                <div class="month-selector-wrapper" style="position: relative; margin-top: 20px;">
                    <asp:LinkButton ID="btnPrevMonth" runat="server" OnClick="ChangeMonth_Click" CommandArgument="-1" CssClass="nav-arrow">&lt;</asp:LinkButton>
                    <asp:LinkButton ID="btnShowPicker" runat="server" OnClick="TogglePicker_Click" CssClass="current-month-display">
                        <asp:Literal ID="litCurrentMonth" runat="server" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNextMonth" runat="server" OnClick="ChangeMonth_Click" CommandArgument="1" CssClass="nav-arrow">&gt;</asp:LinkButton>

                    <asp:Panel ID="pnlPicker" runat="server" Visible="false" CssClass="picker-dropdown">
                        <asp:MultiView ID="mvPicker" runat="server">
                            <asp:View runat="server">
                                <div class="picker-header">
                                    <asp:LinkButton ID="btnSwitchToYear" runat="server" OnClick="btnSwitchToYear_Click" CssClass="year-toggle">
                                        <asp:Literal ID="litPickerYear" runat="server" />
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" OnClick="btnToday_Click" CssClass="action-link blue">Today</asp:LinkButton>
                                </div>
                                <div class="picker-grid">
                                    <asp:Repeater ID="rptMonths" runat="server" OnItemCommand="rptMonths_ItemCommand">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandArgument='<%# Eval("MonthNum") %>' CssClass='<%# Eval("CssClass") %>'>
                                                <%# Eval("MonthName") %>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:View>
                            <asp:View runat="server">
                                <div class="picker-header" style="justify-content: center;">
                                    <span class="decade-label">Select Year</span>
                                </div>
                                <div class="picker-grid">
                                    <asp:Repeater ID="rptYears" runat="server" OnItemCommand="rptYears_ItemCommand">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandArgument='<%# Container.DataItem %>' CssClass="grid-item">
                                                <%# Container.DataItem %>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:View>
                        </asp:MultiView>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <div class="budget-summary">
            Total Allocated: <strong>$<asp:Literal ID="litTotalBudgeted" runat="server" /></strong> 
            | Left to Allocate: <strong>$<asp:Literal ID="litRemaining" runat="server" /></strong>
        </div>

        <div class="add-action-area" style="margin-top: 5px;"> 
            <button type="button" id="mainAddBtn" class="btn-add-toggle" onclick="toggleAddForm(true)">+ Add Category</button>
           <div id="addForm" class="add-form-panel" style="display:none;">
    <asp:DropDownList ID="ddlCategories" runat="server" CssClass="form-select custom-dropdown"></asp:DropDownList>
    
    <div style="position: relative;">
        <asp:TextBox ID="txtAmount" runat="server" placeholder="Limit Amount (e.g. 50.00)" 
            CssClass="form-input" TextMode="SingleLine"></asp:TextBox>
        
        <asp:RegularExpressionValidator ID="revAmount" runat="server" 
            ControlToValidate="txtAmount"
            ValidationExpression="^\d+(\.\d{1,2})?$"
            ErrorMessage="Enter a valid number (no $ or commas)"
            ForeColor="#b91c1c"
            Display="Dynamic"
            Font-Size="12px" />
    </div>

    <div class="form-actions">
        <asp:Button ID="btnSubmitAdd" runat="server" Text="Confirm" 
            OnClick="btnAddCategory_Click" CssClass="btn-add-toggle" />
        <button type="button" class="cancel-btn" onclick="toggleAddForm(false)">Cancel</button>
    </div>
</div>
        </div>
    </div>

    <div id="plannerModal" class="planner-modal">
        <div class="planner-content">
            <div class="planner-header">
                <h4> "What-If" Planner</h4>
                <button type="button" onclick="togglePlanner()" class="close-btn">&times;</button>
            </div>
            <div class="planner-body">
                <label>Category:</label>
                <asp:DropDownList ID="ddlPlannerCats" runat="server" CssClass="form-select custom-dropdown w-100 mb-2" onchange="calculateWhatIf()"></asp:DropDownList>

                <div style="display: flex; gap: 10px; margin-top: 10px;">
                    <div style="flex: 2;">
                        <label>Amt:</label>
                        <input type="number" id="plannerValue" class="form-input w-100" placeholder="0.00" oninput="calculateWhatIf()" />
                    </div>
                    <div style="flex: 1.5;">
                        <label>Type:</label>
                        <select id="plannerType" class="form-select w-100" onchange="calculateWhatIf()">
                            <option value="percent">% Off</option>
                            <option value="decrease">Decrease ($)</option> 
                            <option value="increase">Increase ($)</option>
                        </select>
                    </div>
                </div>

                

                <asp:HiddenField ID="hfProjectedCatID" runat="server" Value="0" />
                <asp:HiddenField ID="hfProjectedValue" runat="server" Value="0" />

                <div class="projection-box" id="resultsBox" style="display: none; background: #f0f9ff; border: 1px solid #bae6fd; padding: 15px; border-radius: 8px; margin-top: 15px;">
                    <p style="margin:0;">New Category Amt: <strong id="newCatValText">$0.00</strong></p>
                    <p style="margin:5px 0;">New Total Budget: <strong id="newTotalText" style="color: #3b82f6;">$0.00</strong></p>
                    <p style="margin:0;">New Savings: <strong id="newSavingsText" style="color: #10b981;">$0.00</strong></p>
                    
                    <asp:Button ID="btnImplement" runat="server" Text="Apply to Budget" 
                        OnClick="btnImplement_Click" CssClass="btn-add-toggle" 
                        style="width:100%; margin-top:15px; background:#10b981; border:none; color:white; padding:10px; border-radius:5px; cursor:pointer;" 
                        OnClientClick="return confirm('Update your actual budget with these numbers?');" />
                </div>
                
                <p id="plannerError" style="color: #ef4444; font-size: 12px; margin-top: 10px; display: none;"></p>
            </div>
        </div>
    </div>

    <script>
        function showToast(message, icon) {
            var toast = document.getElementById('customToast');
            var iconSpan = document.getElementById('toastIcon');
            var lbl = document.getElementById('<%= lblStatus.ClientID %>');

        if (toast && lbl) {
            lbl.innerText = message;
            if (iconSpan) iconSpan.innerText = icon || "✅";
            
            toast.style.display = 'flex'; // Show it
            
            // Auto-hide after 3 seconds
            setTimeout(function () {
                toast.style.display = 'none';
            }, 3000);
        }
    }

    // This handles the initial page load if C# set a message 
    // but the toast is still hidden by the default CSS
    window.onload = function() {
        var lbl = document.getElementById('<%= lblStatus.ClientID %>');
        var toast = document.getElementById('customToast');

        // If C# populated the label, show the toast
        if (lbl && lbl.innerText.trim() !== "") {
            toast.style.display = 'flex';
            setTimeout(function () {
                toast.style.display = 'none';
                lbl.innerText = ""; // Clear it so it doesn't pop up again on refresh
            }, 3000);
        }
    };

        function toggleAddForm(show) {
            const form = document.getElementById('addForm');
            const mainBtn = document.getElementById('mainAddBtn');

            if (show) {
                form.style.display = 'block';
                mainBtn.style.display = 'none';
            } else {
                form.style.display = 'none';
                mainBtn.style.display = 'block';

                // Reset Inputs
                document.getElementById('<%= ddlCategories.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= txtAmount.ClientID %>').value = '';
        
        // Hide Validation Error if it's visible
                var validator = document.getElementById('<%= revAmount.ClientID %>');
                if (validator) { validator.style.display = 'none'; }
            }
        }

        function togglePlanner() {
            const modal = document.getElementById('plannerModal');
            modal.style.display = (modal.style.display === 'flex') ? 'none' : 'flex';
            if (modal.style.display === 'none') {
                document.getElementById('resultsBox').style.display = 'none';
                document.getElementById('plannerError').style.display = 'none';
                document.getElementById('plannerValue').value = '';
            }
        }

        function calculateWhatIf() {
            const errorEl = document.getElementById('plannerError');
            const resultsBox = document.getElementById('resultsBox');

            const getLitVal = (id) => {
                const el = document.getElementById(id);
                return el ? parseFloat(el.innerText.replace(/[^0-9.-]+/g, "")) || 0 : 0;
            };

            const currentTotalAllocated = getLitVal('<%= litTotalBudgeted.ClientID %>');
            const monthlyIncome = getLitVal('<%= litIncomeSub.ClientID %>');
            const targetCatId = document.getElementById('<%= ddlPlannerCats.ClientID %>').value;
            const inputVal = parseFloat(document.getElementById('plannerValue').value);
            const type = document.getElementById('plannerType').value;

            if (isNaN(inputVal) || targetCatId === "" || targetCatId === "0") {
                resultsBox.style.display = 'none';
                return;
            }

            errorEl.style.display = 'none';

            let startValue = 0;
            const row = document.querySelector(`tr[data-catid="${targetCatId}"]`);
            if (row) {
                startValue = parseFloat(row.getAttribute('data-current')) || 0;
            } else {
                return;
            }

            let calculatedNewVal = 0;
            if (type === 'percent') {
                calculatedNewVal = startValue * (1 - (inputVal / 100));
            } else if (type === 'increase') {
                calculatedNewVal = startValue + inputVal;
            } else if (type === 'decrease') {
                calculatedNewVal = Math.max(0, startValue - inputVal);
            }

            const diff = startValue - calculatedNewVal;
            const finalTotal = currentTotalAllocated - diff;
            const finalSavings = monthlyIncome - finalTotal;

            document.getElementById('newCatValText').innerText = '$' + calculatedNewVal.toLocaleString(undefined, { minimumFractionDigits: 2 });
            document.getElementById('newTotalText').innerText = '$' + finalTotal.toLocaleString(undefined, { minimumFractionDigits: 2 });
            document.getElementById('newSavingsText').innerText = '$' + finalSavings.toLocaleString(undefined, { minimumFractionDigits: 2 });

            document.getElementById('<%= hfProjectedCatID.ClientID %>').value = targetCatId;
            document.getElementById('<%= hfProjectedValue.ClientID %>').value = calculatedNewVal.toFixed(2);

            resultsBox.style.display = 'block';
        }
    </script>
</asp:Content>