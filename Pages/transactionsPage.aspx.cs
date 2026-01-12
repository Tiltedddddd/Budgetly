using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using Budgetly.Controllers;
using Budgetly.Models;

namespace Budgetly.Pages
{
    public partial class transactionsPage : Page
    {
        private readonly TransactionsController _controller = new TransactionsController();

        // ===== ViewState keys for filters =====
        private const string VS_IMPORTED_ONLY = "ImportedOnly";
        private const string VS_F_WALLET = "FilterWalletId";
        private const string VS_F_CATEGORY = "FilterCategoryId";
        private const string VS_F_MERCHANT = "FilterMerchant";
        private const string VS_F_MIN = "FilterAmountMin";
        private const string VS_F_MAX = "FilterAmountMax";
        private const string VS_F_FROM = "FilterDateFrom";
        private const string VS_F_TO = "FilterDateTo";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Default to current month
                ddlMonth.SelectedValue = DateTime.Now.Month.ToString();

                // Default filter = All (not imported only)
                ViewState[VS_IMPORTED_ONLY] = false;
                SetToggleUi(importedOnly: false);

                // Initialise filters as empty
                ClearFilterState();

                BindLookupsForEdit();
                BindLookupsForFilters(); // so filter modal dropdowns exist
                BindGrid();
            }
        }

        private int GetCurrentUserId()
        {
            // If you have login/session later, use it.
            // For seed data, UserID 1 exists (Alice).
            if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int id))
                return id;

            return 1;
        }

        // =========================
        // LOOKUPS
        // =========================
        private void BindLookupsForEdit()
        {
            int userId = GetCurrentUserId();

            var accounts = _controller.GetAccountsForUser(userId);
            ddlEditWallet.DataSource = accounts;
            ddlEditWallet.DataTextField = "Name";
            ddlEditWallet.DataValueField = "Id";
            ddlEditWallet.DataBind();

            var cats = _controller.GetCategories();
            ddlEditCategory.DataSource = cats;
            ddlEditCategory.DataTextField = "Name";
            ddlEditCategory.DataValueField = "Id";
            ddlEditCategory.DataBind();
        }

        private void BindLookupsForFilters()
        {
            int userId = GetCurrentUserId();

            // Wallet dropdown: add "All"
            var accounts = _controller.GetAccountsForUser(userId);
            ddlFilterWallet.DataSource = accounts;
            ddlFilterWallet.DataTextField = "Name";
            ddlFilterWallet.DataValueField = "Id";
            ddlFilterWallet.DataBind();
            ddlFilterWallet.Items.Insert(0, new ListItem("All wallets", ""));

            // Category dropdown: add "All"
            var cats = _controller.GetCategories();
            ddlFilterCategory.DataSource = cats;
            ddlFilterCategory.DataTextField = "Name";
            ddlFilterCategory.DataValueField = "Id";
            ddlFilterCategory.DataBind();
            ddlFilterCategory.Items.Insert(0, new ListItem("All categories", ""));
        }

        // =========================
        // GRID BIND
        // =========================
        private void BindGrid()
        {
            int userId = GetCurrentUserId();

            bool importedOnly = ViewState[VS_IMPORTED_ONLY] != null && (bool)ViewState[VS_IMPORTED_ONLY];

            int? month = null;
            if (int.TryParse(ddlMonth.SelectedValue, out int m))
                month = m;

            int? walletId = ViewState[VS_F_WALLET] as int?;
            int? categoryId = ViewState[VS_F_CATEGORY] as int?;
            string merchant = ViewState[VS_F_MERCHANT] as string;

            decimal? amountMin = ViewState[VS_F_MIN] as decimal?;
            decimal? amountMax = ViewState[VS_F_MAX] as decimal?;

            DateTime? dateFrom = ViewState[VS_F_FROM] as DateTime?;
            DateTime? dateTo = ViewState[VS_F_TO] as DateTime?;

            gvTransactions.DataSource = _controller.GetTransactions(
                userId,
                month,
                importedOnly,
                walletId,
                categoryId,
                merchant,
                amountMin,
                amountMax,
                dateFrom,
                dateTo
            );
            gvTransactions.DataBind();

            BindActiveFilterChips();
        }

        // =========================
        // TOGGLE UI
        // =========================
        private void SetToggleUi(bool importedOnly)
        {
            if (importedOnly)
            {
                btnImported.CssClass = "txn-btn is-active";
                btnAll.CssClass = "txn-btn";
            }
            else
            {
                btnAll.CssClass = "txn-btn is-active";
                btnImported.CssClass = "txn-btn";
            }
        }

        protected void btnAll_Click(object sender, EventArgs e)
        {
            ViewState[VS_IMPORTED_ONLY] = false;
            SetToggleUi(importedOnly: false);
            BindGrid();
        }

        protected void btnImported_Click(object sender, EventArgs e)
        {
            ViewState[VS_IMPORTED_ONLY] = true;
            SetToggleUi(importedOnly: true);
            BindGrid();
        }

        protected void ddlMonth_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        // =========================
        // FILTERS MODAL
        // =========================
        protected void btnFilters_Click(object sender, EventArgs e)
        {
            // Ensure lookups exist (in case designer regeneration / postback issues)
            if (ddlFilterWallet.Items.Count == 0 || ddlFilterCategory.Items.Count == 0)
                BindLookupsForFilters();

            LoadFilterUiFromState();
            lblFiltersError.Visible = false;
            pnlFiltersOverlay.Visible = true;
        }

        protected void btnFiltersCancel_Click(object sender, EventArgs e)
        {
            pnlFiltersOverlay.Visible = false;
            lblFiltersError.Visible = false;
        }

        protected void btnFiltersReset_Click(object sender, EventArgs e)
        {
            ClearFilterState();
            LoadFilterUiFromState(); // clears the inputs
            lblFiltersError.Visible = false;

            // Keep modal open so user sees reset happened
            pnlFiltersOverlay.Visible = true;

            BindGrid();
        }

        protected void btnFiltersApply_Click(object sender, EventArgs e)
        {
            try
            {
                // Wallet
                if (int.TryParse(ddlFilterWallet.SelectedValue, out int wId))
                    ViewState[VS_F_WALLET] = (int?)wId;
                else
                    ViewState[VS_F_WALLET] = (int?)null;

                // Category
                if (int.TryParse(ddlFilterCategory.SelectedValue, out int cId))
                    ViewState[VS_F_CATEGORY] = (int?)cId;
                else
                    ViewState[VS_F_CATEGORY] = (int?)null;

                // Merchant contains
                string merchant = string.IsNullOrWhiteSpace(txtFilterMerchant.Text) ? null : txtFilterMerchant.Text.Trim();
                ViewState[VS_F_MERCHANT] = merchant;

                // Amount min/max
                ViewState[VS_F_MIN] = ParseNullableDecimal(txtAmountMin.Text);
                ViewState[VS_F_MAX] = ParseNullableDecimal(txtAmountMax.Text);

                // Date from/to (yyyy-MM-dd from TextMode="Date")
                ViewState[VS_F_FROM] = ParseNullableDate(txtDateFrom.Text);
                ViewState[VS_F_TO] = ParseNullableDate(txtDateTo.Text);

                // Validate min <= max if both
                var min = ViewState[VS_F_MIN] as decimal?;
                var max = ViewState[VS_F_MAX] as decimal?;
                if (min.HasValue && max.HasValue && min.Value > max.Value)
                    throw new InvalidOperationException("Amount min cannot be greater than amount max.");

                // Validate dateFrom <= dateTo if both
                var dFrom = ViewState[VS_F_FROM] as DateTime?;
                var dTo = ViewState[VS_F_TO] as DateTime?;
                if (dFrom.HasValue && dTo.HasValue && dFrom.Value.Date > dTo.Value.Date)
                    throw new InvalidOperationException("Date from cannot be after date to.");

                pnlFiltersOverlay.Visible = false;
                lblFiltersError.Visible = false;

                BindGrid();
            }
            catch (Exception ex)
            {
                lblFiltersError.Text = ex.Message;
                lblFiltersError.Visible = true;
                pnlFiltersOverlay.Visible = true; // keep modal open
            }
        }

        private void LoadFilterUiFromState()
        {
            // dropdown selected values
            var walletId = ViewState[VS_F_WALLET] as int?;
            ddlFilterWallet.ClearSelection();
            if (walletId.HasValue && ddlFilterWallet.Items.FindByValue(walletId.Value.ToString()) != null)
                ddlFilterWallet.SelectedValue = walletId.Value.ToString();
            else
                ddlFilterWallet.SelectedValue = "";

            var categoryId = ViewState[VS_F_CATEGORY] as int?;
            ddlFilterCategory.ClearSelection();
            if (categoryId.HasValue && ddlFilterCategory.Items.FindByValue(categoryId.Value.ToString()) != null)
                ddlFilterCategory.SelectedValue = categoryId.Value.ToString();
            else
                ddlFilterCategory.SelectedValue = "";

            // text inputs
            txtFilterMerchant.Text = ViewState[VS_F_MERCHANT] as string ?? "";

            txtAmountMin.Text = (ViewState[VS_F_MIN] as decimal?)?.ToString(CultureInfo.InvariantCulture) ?? "";
            txtAmountMax.Text = (ViewState[VS_F_MAX] as decimal?)?.ToString(CultureInfo.InvariantCulture) ?? "";

            txtDateFrom.Text = (ViewState[VS_F_FROM] as DateTime?)?.ToString("yyyy-MM-dd") ?? "";
            txtDateTo.Text = (ViewState[VS_F_TO] as DateTime?)?.ToString("yyyy-MM-dd") ?? "";
        }

        private void ClearFilterState()
        {
            ViewState[VS_F_WALLET] = (int?)null;
            ViewState[VS_F_CATEGORY] = (int?)null;
            ViewState[VS_F_MERCHANT] = null;
            ViewState[VS_F_MIN] = (decimal?)null;
            ViewState[VS_F_MAX] = (decimal?)null;
            ViewState[VS_F_FROM] = (DateTime?)null;
            ViewState[VS_F_TO] = (DateTime?)null;
        }

        private decimal? ParseNullableDecimal(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;

            if (!decimal.TryParse(input.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out var value))
                throw new InvalidOperationException("Please enter a valid number for amount.");

            if (value < 0) throw new InvalidOperationException("Amount cannot be negative.");
            return value;
        }

        private DateTime? ParseNullableDate(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;

            if (!DateTime.TryParseExact(input.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var dt))
                throw new InvalidOperationException("Please enter a valid date.");

            return dt.Date;
        }

        // =========================
        // ACTIVE FILTER CHIPS
        // =========================
        private class FilterChip
        {
            public string Key { get; set; }
            public string Text { get; set; }
        }

        private void BindActiveFilterChips()
        {
            var chips = new List<FilterChip>();

            // Wallet chip: show wallet name
            var walletId = ViewState[VS_F_WALLET] as int?;
            if (walletId.HasValue)
            {
                string walletName = ddlFilterWallet.Items.FindByValue(walletId.Value.ToString())?.Text ?? "Wallet";
                chips.Add(new FilterChip { Key = "wallet", Text = $"Wallet: {walletName}" });
            }

            // Category chip
            var categoryId = ViewState[VS_F_CATEGORY] as int?;
            if (categoryId.HasValue)
            {
                string catName = ddlFilterCategory.Items.FindByValue(categoryId.Value.ToString())?.Text ?? "Category";
                chips.Add(new FilterChip { Key = "category", Text = $"Category: {catName}" });
            }

            // Merchant
            var merchant = ViewState[VS_F_MERCHANT] as string;
            if (!string.IsNullOrWhiteSpace(merchant))
                chips.Add(new FilterChip { Key = "merchant", Text = $"Merchant: {merchant}" });

            // Amount range
            var min = ViewState[VS_F_MIN] as decimal?;
            var max = ViewState[VS_F_MAX] as decimal?;
            if (min.HasValue || max.HasValue)
            {
                if (min.HasValue && max.HasValue)
                    chips.Add(new FilterChip { Key = "amount", Text = $"Amount: {min.Value:0.##}–{max.Value:0.##}" });
                else if (min.HasValue)
                    chips.Add(new FilterChip { Key = "amount", Text = $"Amount: ≥ {min.Value:0.##}" });
                else
                    chips.Add(new FilterChip { Key = "amount", Text = $"Amount: ≤ {max.Value:0.##}" });
            }

            // Date range
            var dFrom = ViewState[VS_F_FROM] as DateTime?;
            var dTo = ViewState[VS_F_TO] as DateTime?;
            if (dFrom.HasValue || dTo.HasValue)
            {
                if (dFrom.HasValue && dTo.HasValue)
                    chips.Add(new FilterChip { Key = "date", Text = $"Date: {dFrom:dd/MM/yyyy}–{dTo:dd/MM/yyyy}" });
                else if (dFrom.HasValue)
                    chips.Add(new FilterChip { Key = "date", Text = $"Date: from {dFrom:dd/MM/yyyy}" });
                else
                    chips.Add(new FilterChip { Key = "date", Text = $"Date: to {dTo:dd/MM/yyyy}" });
            }

            rptActiveFilters.DataSource = chips;
            rptActiveFilters.DataBind();

            btnClearAllFilters.Visible = chips.Count > 0;
        }

        protected void rptActiveFilters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Remove") return;

            string key = e.CommandArgument?.ToString() ?? "";

            switch (key)
            {
                case "wallet":
                    ViewState[VS_F_WALLET] = (int?)null;
                    break;
                case "category":
                    ViewState[VS_F_CATEGORY] = (int?)null;
                    break;
                case "merchant":
                    ViewState[VS_F_MERCHANT] = null;
                    break;
                case "amount":
                    ViewState[VS_F_MIN] = (decimal?)null;
                    ViewState[VS_F_MAX] = (decimal?)null;
                    break;
                case "date":
                    ViewState[VS_F_FROM] = (DateTime?)null;
                    ViewState[VS_F_TO] = (DateTime?)null;
                    break;
            }

            // Keep filter UI in sync next time user opens modal
            BindGrid();
        }

        protected void btnClearAllFilters_Click(object sender, EventArgs e)
        {
            ClearFilterState();
            BindGrid();
        }

        // =========================
        // ADD MODAL
        // =========================
        protected void btnManualAdd_Click(object sender, EventArgs e)
        {
            OpenModalForAdd();
        }

        private void OpenModalForAdd()
        {
            lblModalTitle.Text = "Add Transaction";
            hfMode.Value = "ADD";
            hfTransactionId.Value = "";

            ddlType.SelectedValue = "EXPENSE";
            txtMerchant.Text = "";
            txtAmount.Text = "";
            txtDescription.Text = "";

            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            if (ddlEditWallet.Items.Count > 0) ddlEditWallet.SelectedIndex = 0;
            if (ddlEditCategory.Items.Count > 0) ddlEditCategory.SelectedIndex = 0;

            lblModalError.Visible = false;
            pnlModalOverlay.Visible = true;
        }

        // =========================
        // GRID ACTIONS (Edit/Delete)
        // =========================
        protected void gvTransactions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = GetCurrentUserId();

            if (!int.TryParse(e.CommandArgument?.ToString(), out int transactionId))
                return;

            if (e.CommandName == "EditTxn")
            {
                var dto = _controller.GetTransactionForEdit(userId, transactionId);
                if (dto == null) return;

                OpenModalForEdit(dto);
                return;
            }

            if (e.CommandName == "DeleteTxn")
            {
                _controller.DeleteTransaction(userId, transactionId);
                BindGrid();
                return;
            }
        }

        private void OpenModalForEdit(TransactionEditDto dto)
        {
            lblModalTitle.Text = "Edit Transaction";
            hfMode.Value = "EDIT";
            hfTransactionId.Value = dto.TransactionID.ToString();

            ddlEditWallet.SelectedValue = dto.AccountID.ToString();
            ddlEditCategory.SelectedValue = dto.CategoryID.ToString();

            txtMerchant.Text = dto.Merchant ?? "";
            txtAmount.Text = dto.Amount.ToString("0.00", CultureInfo.InvariantCulture);
            txtDescription.Text = dto.Description ?? "";

            ddlType.SelectedValue = dto.TransactionType;

            txtDate.Text = dto.TransactionDate.ToString("yyyy-MM-dd");

            lblModalError.Visible = false;
            pnlModalOverlay.Visible = true;
        }

        // =========================
        // EDIT/ADD MODAL BUTTONS
        // =========================
        protected void btnModalCancel_Click(object sender, EventArgs e)
        {
            pnlModalOverlay.Visible = false;
            lblModalError.Visible = false;
        }

        protected void btnModalSave_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();

            try
            {
                if (!int.TryParse(ddlEditWallet.SelectedValue, out int accountId))
                    throw new InvalidOperationException("Please select a wallet.");

                if (!int.TryParse(ddlEditCategory.SelectedValue, out int categoryId))
                    throw new InvalidOperationException("Please select a category.");

                if (!decimal.TryParse(txtAmount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out decimal amount) || amount <= 0)
                    throw new InvalidOperationException("Please enter a valid amount (> 0).");

                if (!DateTime.TryParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime date))
                    throw new InvalidOperationException("Please select a valid date.");

                string type = ddlType.SelectedValue;
                if (type != "INCOME" && type != "EXPENSE")
                    throw new InvalidOperationException("Invalid transaction type.");

                var dto = new TransactionEditDto
                {
                    AccountID = accountId,
                    CategoryID = categoryId,
                    Amount = amount,
                    TransactionType = type,
                    TransactionDate = date,
                    Merchant = string.IsNullOrWhiteSpace(txtMerchant.Text) ? null : txtMerchant.Text.Trim(),
                    Description = string.IsNullOrWhiteSpace(txtDescription.Text) ? null : txtDescription.Text.Trim()
                };

                string mode = hfMode.Value ?? "";

                if (mode == "ADD")
                {
                    _controller.InsertManualTransaction(userId, dto);
                }
                else if (mode == "EDIT")
                {
                    if (!int.TryParse(hfTransactionId.Value, out int txId))
                        throw new InvalidOperationException("Missing transaction id.");

                    dto.TransactionID = txId;
                    _controller.UpdateTransaction(userId, dto);
                }
                else
                {
                    throw new InvalidOperationException("Unknown form mode.");
                }

                pnlModalOverlay.Visible = false;
                lblModalError.Visible = false;

                BindGrid();
            }
            catch (Exception ex)
            {
                lblModalError.Text = ex.Message;
                lblModalError.Visible = true;
                pnlModalOverlay.Visible = true; // keep modal open
            }
        }
    }
}


