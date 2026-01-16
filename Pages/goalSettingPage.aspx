<%@ Page Title="Budgets" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="goalSettingPage.aspx.cs" Inherits="Budgetly.Pages.goalSettingPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link href="../Content/css/goalSettingPage.css" rel="stylesheet" />

    <!-- Toast -->
    <div id="notificationZone">
        <div id="customToast" class="planner-toast" style="display:none;">
            <span id="toastIcon">✅</span>
            <asp:Label ID="lblStatus" runat="server" CssClass="status-message"></asp:Label>
        </div>
    </div>

    <div class="goal-card">
        <div class="income-section">
            <div>
                <p class="income-label">
                    Monthly Income:
                    <span class="income-amount">
                        $<span id="incomeVal"><asp:Literal ID="litIncomeSub" runat="server" /></span>
                    </span>
                </p>

                <p class="income-label">
                    Monthly Budget Limit:
                    <span class="income-amount">
                        $<span id="budgetLimitVal"><asp:Literal ID="litBudgetAmount" runat="server" /></span>
                    </span>
                </p>
            </div>

            <div class="planner-inline-trigger">
                <button type="button" class="btn-bell-inline" onclick="togglePlanner(true)">
                    <span>Budget Forecast</span>
                </button>
            </div>
        </div>

        <asp:Panel ID="pnlBudgetWarning" runat="server" CssClass="budget-warning-alert" Visible="false">
            <strong>Warning:</strong> You have exceeded your budget by
            $<asp:Literal ID="litOverAmount" runat="server" />!
        </asp:Panel>
<!-- ACTION BAR -->
<div class="workflow-actions">
    <div class="workflow-left">
        <asp:LinkButton ID="btnCopyLastMonth" runat="server"
            OnClick="btnCopyLastMonth_Click"
            CssClass="btn-template"
            CausesValidation="false">
            Copy Last Month's Goals
        </asp:LinkButton>
    </div>

    <div class="workflow-right">
        <asp:LinkButton ID="btnIncomeAction" runat="server"
            OnClick="btnIncomeAction_Click"
            CssClass="btn-template"
            CausesValidation="false">
            Update Income
        </asp:LinkButton>

        <asp:LinkButton ID="btnBudgetLimitAction" runat="server"
            OnClick="btnBudgetLimitAction_Click"
            CssClass="btn-template"
            CausesValidation="false">
            Update Budget Limit
        </asp:LinkButton>
    </div>
</div>

<!-- INLINE EDIT: INCOME -->
<asp:Panel ID="pnlIncomeEdit" runat="server" Visible="false" CssClass="inline-edit-row">
    <span class="inline-edit-label">Monthly Income ($):</span>

    <div class="inline-edit-field">
        <asp:TextBox ID="txtIncomeEdit" runat="server"
            CssClass="form-input inline-edit-input"
            TextMode="SingleLine"
            placeholder="e.g. 2500.00"></asp:TextBox>

        <asp:RegularExpressionValidator ID="revIncome" runat="server"
            ControlToValidate="txtIncomeEdit"
            ValidationExpression="^\d+(\.\d{1,2})?$"
            ErrorMessage="Enter a valid number (max 2 dp)."
            ForeColor="#b91c1c"
            Display="Dynamic"
            Font-Size="11px"
            ValidationGroup="IncomeGroup" />
    </div>

    <asp:Button ID="btnSaveIncome" runat="server"
        Text="Save"
        CssClass="btn-add-toggle"
        ValidationGroup="IncomeGroup"
        CausesValidation="true"
        OnClick="btnSaveIncome_Click" />

    <asp:LinkButton ID="btnCancelIncome" runat="server"
        CssClass="action-link muted"
        CausesValidation="false"
        OnClick="btnCancelIncome_Click">
        Cancel
    </asp:LinkButton>
</asp:Panel>

<!-- INLINE EDIT: BUDGET LIMIT -->
<asp:Panel ID="pnlBudgetEdit" runat="server" Visible="false" CssClass="inline-edit-row">
    <span class="inline-edit-label">Budget Limit ($):</span>

    <div class="inline-edit-field">
        <asp:TextBox ID="txtBudgetLimitEdit" runat="server"
            CssClass="form-input inline-edit-input"
            TextMode="SingleLine"
            placeholder="e.g. 1500.00"></asp:TextBox>

        <asp:RegularExpressionValidator ID="revBudgetLimit" runat="server"
            ControlToValidate="txtBudgetLimitEdit"
            ValidationExpression="^\d+(\.\d{1,2})?$"
            ErrorMessage="Enter a valid number (max 2 dp)."
            ForeColor="#b91c1c"
            Display="Dynamic"
            Font-Size="11px"
            ValidationGroup="BudgetGroup" />

        <!-- budget must be <= income -->
        <asp:CustomValidator ID="cvBudgetVsIncome" runat="server"
            ControlToValidate="txtBudgetLimitEdit"
            OnServerValidate="cvBudgetVsIncome_ServerValidate"
            ErrorMessage="Budget limit must be ≤ income."
            ForeColor="#b91c1c"
            Display="Dynamic"
            Font-Size="11px"
            ValidationGroup="BudgetGroup" />
    </div>

    <asp:Button ID="btnSaveBudgetLimit" runat="server"
        Text="Save"
        CssClass="btn-add-toggle"
        ValidationGroup="BudgetGroup"
        CausesValidation="true"
        OnClick="btnSaveBudgetLimit_Click" />

    <asp:LinkButton ID="btnCancelBudgetLimit" runat="server"
        CssClass="action-link muted"
        CausesValidation="false"
        OnClick="btnCancelBudgetLimit_Click">
        Cancel
    </asp:LinkButton>
</asp:Panel>


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
                        <asp:Repeater ID="rptBudgetEnvelopes" runat="server"
                            OnItemCommand="rptBudgetEnvelopes_ItemCommand"
                            OnItemDataBound="rptBudgetEnvelopes_ItemDataBound">

                            <ItemTemplate>
                                <tr data-catid='<%# Eval("CategoryID") %>' data-current='<%# Eval("MonthlyLimit") %>'>
                                    <td class="col-category"><%# Eval("CategoryName") %></td>

                                    <td class="col-amount">
                                        <asp:PlaceHolder runat="server"
                                            Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) != EditingID %>'>
                                            $<%# Eval("MonthlyLimit", "{0:N2}") %>
                                        </asp:PlaceHolder>

                                        <asp:PlaceHolder runat="server"
                                            Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) == EditingID %>'>
                                            <!-- NOTE: step cannot be an attribute on asp:TextBox directly; it is added in ItemDataBound -->
                                            <asp:TextBox ID="txtInlineAmount" runat="server"
                                                Text='<%# Eval("MonthlyLimit") %>'
                                                CssClass="form-input"
                                                TextMode="Number"></asp:TextBox>
                                        </asp:PlaceHolder>
                                    </td>

                                    <td class="col-health">
                                        <div class="progress-track">
                                            <div class='<%# "progress-fill " + GetHealthClass(Eval("SpentAmount"), Eval("MonthlyLimit")) %>'
                                                style='<%# string.Format("width: {0}%;", GetProgressWidth(Eval("SpentAmount"), Eval("MonthlyLimit"))) %>'>
                                            </div>
                                        </div>
                                        <small class="progress-subtext">$<%# Eval("SpentAmount", "{0:N0}") %> spent</small>
                                    </td>

                                    <td class="col-amount">
                                        <strong>$<%# (Convert.ToDecimal(Eval("MonthlyLimit")) - Convert.ToDecimal(Eval("SpentAmount"))).ToString("N2") %></strong>
                                    </td>

                                    <td class="col-actions" style="text-align:center;">
                                        <asp:PlaceHolder runat="server"
                                            Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) != EditingID %>'>
                                            <asp:LinkButton ID="btnEdit" runat="server"
                                                CommandName="StartEdit"
                                                CommandArgument='<%# Eval("EnvelopeID") %>'
                                                CssClass="action-link blue"
                                                CausesValidation="false">Edit</asp:LinkButton>

                                            <span class="sep">|</span>

                                            <asp:LinkButton ID="btnDelete" runat="server"
                                                CommandName="DeleteCategory"
                                                CommandArgument='<%# Eval("EnvelopeID") %>'
                                                CssClass="action-link red"
                                                CausesValidation="false"
                                                OnClientClick="return confirm('Delete this category?');">Delete</asp:LinkButton>
                                        </asp:PlaceHolder>

                                        <asp:PlaceHolder runat="server"
                                            Visible='<%# Convert.ToInt32(Eval("EnvelopeID")) == EditingID %>'>
                                            <asp:LinkButton ID="btnSave" runat="server"
                                                CommandName="SaveEdit"
                                                CommandArgument='<%# Eval("EnvelopeID") %>'
                                                CssClass="action-link blue">Save</asp:LinkButton>

                                            <span class="sep">|</span>

                                            <asp:LinkButton ID="btnCancel" runat="server"
                                                CommandName="CancelEdit"
                                                CssClass="action-link muted"
                                                CausesValidation="false">Cancel</asp:LinkButton>
                                        </asp:PlaceHolder>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>

               <!-- Month picker -->
<div class="month-selector-wrapper" style="position:relative; margin-top:20px;">

    <asp:LinkButton ID="btnPrevMonth" runat="server"
        OnClick="ChangeMonth_Click" CommandArgument="-1"
        CssClass="nav-arrow" CausesValidation="false">
        &lt;
    </asp:LinkButton>

    <asp:LinkButton ID="btnShowPicker" runat="server"
        OnClick="TogglePicker_Click"
        CssClass="current-month-display"
        CausesValidation="false">
        <asp:Literal ID="litCurrentMonth" runat="server" />
    </asp:LinkButton>

    <asp:LinkButton ID="btnNextMonth" runat="server"
        OnClick="ChangeMonth_Click" CommandArgument="1"
        CssClass="nav-arrow" CausesValidation="false">
        &gt;
    </asp:LinkButton>

    <asp:Panel ID="pnlPicker" runat="server" Visible="false" CssClass="picker-dropdown">
        <asp:MultiView ID="mvPicker" runat="server">

            <!-- MONTH VIEW -->
            <asp:View runat="server">
                <!-- TOP HEADER: arrows + year -->
                <div class="picker-header picker-yearbar">

                    <asp:LinkButton ID="btnPrevYear" runat="server"
                        CommandArgument="-1"
                        OnClick="ChangeYear_Click"
                        CssClass="year-arrow"
                        CausesValidation="false">
                        &lt;
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnSwitchToYear" runat="server"
                        OnClick="btnSwitchToYear_Click"
                        CssClass="year-toggle"
                        CausesValidation="false">
                        <asp:Literal ID="litPickerYear" runat="server" />
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnNextYear" runat="server"
                        CommandArgument="1"
                        OnClick="ChangeYear_Click"
                        CssClass="year-arrow"
                        CausesValidation="false">
                        &gt;
                    </asp:LinkButton>

                </div>

                <!-- MONTH GRID -->
                <div class="picker-grid">
                    <asp:Repeater ID="rptMonths" runat="server" OnItemCommand="rptMonths_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandArgument='<%# Eval("MonthNum") %>'
                                CssClass='<%# Eval("CssClass") %>'
                                CausesValidation="false">
                                <%# Eval("MonthName") %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>

            <!-- YEAR VIEW -->
            <asp:View runat="server">
                <div class="picker-header" style="justify-content:center;">
                    <span class="decade-label">Select Year</span>
                </div>

                <div class="picker-grid">
                    <asp:Repeater ID="rptYears" runat="server" OnItemCommand="rptYears_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandArgument='<%# Container.DataItem %>'
                                CssClass="grid-item"
                                CausesValidation="false">
                                <%# Container.DataItem %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:View>

        </asp:MultiView>
    </asp:Panel>

</div>


        <!-- Summary (wrapped spans so JS can read them) -->
        <div class="budget-summary">
            Total Allocated:
            <strong>$<span id="totalAllocatedVal"><asp:Literal ID="litTotalBudgeted" runat="server" /></span></strong>
            | Left to Allocate:
            <strong>$<span id="remainingVal"><asp:Literal ID="litRemaining" runat="server" /></span></strong>
        </div>

        <!-- Add Category -->
        <div class="add-action-area" style="margin-top:5px;">
            <button type="button" id="mainAddBtn" class="btn-add-toggle" onclick="toggleAddForm(true)">
                + Add Category
            </button>

            <div id="addForm" class="add-form-panel" style="display:none;">
                <asp:DropDownList ID="ddlCategories" runat="server"
                    CssClass="form-select custom-dropdown add-inline"></asp:DropDownList>

                <div class="amount-inline">
                    <asp:TextBox ID="txtAmount" runat="server"
                        placeholder="Limit Amount"
                        CssClass="form-input add-inline"
                        TextMode="SingleLine"></asp:TextBox>

                    <asp:RegularExpressionValidator ID="revAmount" runat="server"
                        ControlToValidate="txtAmount"
                        ValidationExpression="^\d+(\.\d{1,2})?$"
                        ErrorMessage="Invalid amount"
                        ForeColor="#b91c1c"
                        Display="Dynamic"
                        Font-Size="11px" />
                </div>

                <div class="form-actions-inline">
                    <asp:Button ID="btnSubmitAdd" runat="server"
                        Text="Confirm"
                        CssClass="btn-add-toggle"
                        OnClick="btnAddCategory_Click" />

                    <button type="button" class="cancel-btn" onclick="toggleAddForm(false)">
                        Cancel
                    </button>
                </div>
            </div>
        </div>

        <!-- 🔒 Hidden replace mechanism -->
        <asp:HiddenField ID="hfReplaceEnvId" runat="server" />
        <asp:HiddenField ID="hfReplaceAmt" runat="server" />
        <asp:Button ID="btnReplaceHidden" runat="server"
            OnClick="btnReplaceHidden_Click"
            CausesValidation="false"
            UseSubmitBehavior="false"
            Style="display:none;" />

        <!-- What-If Planner Modal -->
        <div id="plannerModal" class="planner-modal" style="display:none;">
            <div class="planner-content">
                <div class="planner-header">
                    <h4>"What-If" Planner</h4>
                    <button type="button" onclick="togglePlanner(false)" class="close-btn">&times;</button>
                </div>

                <div class="planner-body">
                    <label>Category:</label>
                    <asp:DropDownList ID="ddlPlannerCats" runat="server"
                        CssClass="form-select custom-dropdown w-100 mb-2"
                        onchange="calculateWhatIf()"></asp:DropDownList>

                    <div style="display:flex; gap:10px; margin-top:10px;">
                        <div style="flex:2;">
                            <label>Amt:</label>
                            <input type="number" id="plannerValue" class="form-input w-100"
                                placeholder="0.00" oninput="calculateWhatIf()" />
                        </div>

                        <div style="flex:1.5;">
                            <label>Type:</label>
                            <select id="plannerType" class="form-select w-100" onchange="calculateWhatIf()">
                                <option value="percentOff">Decrease (%)</option>
                                <option value="percentIncrease">Increase (%)</option>
                                <option value="decrease">Decrease ($)</option>
                                <option value="increase">Increase ($)</option>
                            </select>
                        </div>
                    </div>

                    <asp:HiddenField ID="hfProjectedCatID" runat="server" Value="0" />
                    <asp:HiddenField ID="hfProjectedValue" runat="server" Value="0" />

                    <div class="projection-box" id="resultsBox"
                        style="display:none; background:#f0f9ff; border:1px solid #bae6fd; padding:15px; border-radius:8px; margin-top:15px;">

                        <p style="margin:0;">
                            New Category Amt: <strong id="newCatValText">$0.00</strong>
                        </p>

                        <p style="margin:5px 0;">
                            New Total Budget: <strong id="newTotalText" style="color:#3b82f6;">$0.00</strong>
                        </p>

                        <p style="margin:0;">
                            New Savings: <strong id="newSavingsText" style="color:#10b981;">$0.00</strong>
                        </p>

                        <asp:Button ID="btnImplement" runat="server" Text="Apply to Budget"
                            OnClick="btnImplement_Click"
                            CssClass="btn-add-toggle"
                            style="width:100%; margin-top:15px; background:#10b981; border:none; color:white; padding:10px; border-radius:5px; cursor:pointer;"
                            OnClientClick="return applyWhatIfAndClose();" />
                    </div>

                    <p id="plannerError" style="color:#ef4444; font-size:12px; margin-top:10px; display:none;"></p>
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

                    toast.style.display = 'flex';
                    setTimeout(function () { toast.style.display = 'none'; }, 3000);
                }
            }

            window.onload = function () {
                var lbl = document.getElementById('<%= lblStatus.ClientID %>');
                var toast = document.getElementById('customToast');

                if (lbl && lbl.innerText.trim() !== "") {
                    toast.style.display = 'flex';
                    setTimeout(function () {
                        toast.style.display = 'none';
                        lbl.innerText = "";
                    }, 3000);
                }
            };

            function toggleAddForm(show) {
                const form = document.getElementById('addForm');
                const mainBtn = document.getElementById('mainAddBtn');
                if (!form || !mainBtn) return;

                if (show) {
                    form.style.display = 'flex';
                    form.style.flexWrap = 'nowrap';
                    form.style.alignItems = 'center';
                    form.style.gap = '12px';
                    mainBtn.style.display = 'none';
                } else {
                    form.style.display = 'none';
                    mainBtn.style.display = 'inline-block';

                    const ddl = document.getElementById('<%= ddlCategories.ClientID %>');
                    const amt = document.getElementById('<%= txtAmount.ClientID %>');
                    if (ddl) ddl.selectedIndex = 0;
                    if (amt) amt.value = '';

                    const validator = document.getElementById('<%= revAmount.ClientID %>');
                    if (validator) validator.style.display = 'none';
                }
            }

            function togglePlanner(forceOpen) {
                const modal = document.getElementById('plannerModal');
                if (!modal) return;

                const shouldOpen = (typeof forceOpen === "boolean")
                    ? forceOpen
                    : (modal.style.display !== 'flex');

                modal.style.display = shouldOpen ? 'flex' : 'none';

                if (!shouldOpen) {
                    const resultsBox = document.getElementById('resultsBox');
                    const errorEl = document.getElementById('plannerError');
                    const plannerValue = document.getElementById('plannerValue');
                    if (resultsBox) resultsBox.style.display = 'none';
                    if (errorEl) errorEl.style.display = 'none';
                    if (plannerValue) plannerValue.value = '';
                }
            }

            function closePlanner() { togglePlanner(false); }

            function calculateWhatIf() {
                const resultsBox = document.getElementById('resultsBox');
                const errorEl = document.getElementById('plannerError');
                if (!resultsBox) return;

                const showErr = (msg) => {
                    resultsBox.style.display = 'none';
                    if (errorEl) {
                        errorEl.innerText = msg;
                        errorEl.style.display = 'block';
                    }
                };

                const hideErr = () => { if (errorEl) errorEl.style.display = 'none'; };

                const getLitVal = (id) => {
                    const el = document.getElementById(id);
                    return el ? parseFloat((el.innerText || "").replace(/[^0-9.-]+/g, "")) || 0 : 0;
                };

                const currentTotalAllocated = getLitVal('totalAllocatedVal');
                const monthlyIncome = getLitVal('incomeVal');

                const ddl = document.getElementById('<%= ddlPlannerCats.ClientID %>');
                const targetCatId = ddl ? ddl.value : "0";

                const inputEl = document.getElementById('plannerValue');
                const typeEl = document.getElementById('plannerType');

                const inputVal = parseFloat(inputEl.value);
                const type = typeEl.value;

                if (isNaN(inputVal) || targetCatId === "" || targetCatId === "0") {
                    resultsBox.style.display = 'none';
                    hideErr();
                    return;
                }

                if (inputVal < 0) {
                    showErr("Amount must be 0 or more.");
                    return;
                }

                // percent guard: > 100 not allowed; prompt to switch to $
                const isPercentType = (type === 'percentOff' || type === 'percentIncrease');
                if (isPercentType && inputVal > 100) {
                    const wantsDollar = confirm("Percent cannot be more than 100%. Switch to $ change instead?");
                    if (wantsDollar) {
                        typeEl.value = (type === 'percentOff') ? 'decrease' : 'increase';
                        inputEl.value = '';
                        showErr("Switched to $ change. Please enter a dollar amount.");
                    } else {
                        showErr("Percent cannot be more than 100%. Enter 100 or less.");
                    }
                    return;
                }

                hideErr();

                const row = document.querySelector(`tr[data-catid="${targetCatId}"]`);
                if (!row) {
                    showErr("Cannot find that category row in the table.");
                    return;
                }

                const startValue = parseFloat(row.getAttribute('data-current')) || 0;

                let calculatedNewVal = startValue;
                switch (type) {
                    case 'percentOff':
                        calculatedNewVal = startValue * (1 - inputVal / 100);
                        break;
                    case 'percentIncrease':
                        calculatedNewVal = startValue * (1 + inputVal / 100);
                        break;
                    case 'decrease':
                        calculatedNewVal = Math.max(0, startValue - inputVal);
                        break;
                    case 'increase':
                        calculatedNewVal = startValue + inputVal;
                        break;
                }

                const diff = startValue - calculatedNewVal;
                const finalTotal = currentTotalAllocated - diff;
                const finalSavings = monthlyIncome - finalTotal;

                const fmtMoney = (n) =>
                    '$' + (Number(n) || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                document.getElementById('newCatValText').innerText = fmtMoney(calculatedNewVal);
                document.getElementById('newTotalText').innerText = fmtMoney(finalTotal);
                document.getElementById('newSavingsText').innerText = fmtMoney(finalSavings);

                document.getElementById('<%= hfProjectedCatID.ClientID %>').value = targetCatId;
                document.getElementById('<%= hfProjectedValue.ClientID %>').value = calculatedNewVal.toFixed(2);

                resultsBox.style.display = 'block';
            }

            function applyWhatIfAndClose() {
                if (!confirm('Update your actual budget with these numbers?')) return false;
                closePlanner();
                return true;
            }
        </script>
    </div>
</asp:Content>
