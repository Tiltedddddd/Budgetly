using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using Budgetly.Models;

namespace Budgetly.Controllers
{
    public class TransactionsController
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["BudgetlyDBContext"].ConnectionString;

        // =========================
        // LOOKUPS
        // =========================
        public List<LookupItem> GetAccountsForUser(int userId)
        {
            var list = new List<LookupItem>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
SELECT AccountID, AccountName
FROM Accounts
WHERE UserID = @UserID
ORDER BY AccountName;
";
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new LookupItem
                        {
                            Id = r.GetInt32(0),
                            Name = r.GetString(1)
                        });
                    }
                }
            }

            return list;
        }

        public List<LookupItem> GetCategories()
        {
            var list = new List<LookupItem>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
SELECT CategoryID, CategoryName
FROM Categories
ORDER BY CategoryName;
";
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new LookupItem
                        {
                            Id = r.GetInt32(0),
                            Name = r.GetString(1)
                        });
                    }
                }
            }

            return list;
        }

        // =========================
        // GRID LISTING (WITH FILTERS)
        // =========================
        public List<TransactionRowDto> GetTransactions(
            int userId,
            int? month,
            bool importedOnly,
            int? walletAccountId,
            int? categoryId,
            string merchantContains,
            decimal? amountMin,
            decimal? amountMax,
            DateTime? dateFrom,
            DateTime? dateTo)
        {
            var list = new List<TransactionRowDto>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
SELECT
    t.TransactionID,
    c.CategoryName AS Category,
    ISNULL(t.Merchant,'') AS Merchant,
    t.Amount,
    t.TransactionDate AS [Date],
    a.AccountName AS Wallet
FROM Transactions t
JOIN Accounts a ON t.AccountID = a.AccountID
JOIN Categories c ON t.CategoryID = c.CategoryID
WHERE a.UserID = @UserID
  AND (@Month IS NULL OR MONTH(t.TransactionDate) = @Month)
  AND (@ImportedOnly = 0 OR t.Source IN ('GMAIL','IMPORT'))
  AND (@WalletId IS NULL OR t.AccountID = @WalletId)
  AND (@CategoryId IS NULL OR t.CategoryID = @CategoryId)
  AND (@Merchant IS NULL OR t.Merchant LIKE '%' + @Merchant + '%')
  AND (@AmountMin IS NULL OR t.Amount >= @AmountMin)
  AND (@AmountMax IS NULL OR t.Amount <= @AmountMax)
  AND (@DateFrom IS NULL OR t.TransactionDate >= @DateFrom)
  AND (@DateTo IS NULL OR t.TransactionDate < DATEADD(day, 1, @DateTo))
ORDER BY t.TransactionDate DESC, t.TransactionID DESC;
";
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@Month", SqlDbType.Int).Value = (object)month ?? DBNull.Value;
                cmd.Parameters.Add("@ImportedOnly", SqlDbType.Bit).Value = importedOnly;

                cmd.Parameters.Add("@WalletId", SqlDbType.Int).Value = (object)walletAccountId ?? DBNull.Value;
                cmd.Parameters.Add("@CategoryId", SqlDbType.Int).Value = (object)categoryId ?? DBNull.Value;

                cmd.Parameters.Add("@Merchant", SqlDbType.NVarChar, 200).Value =
                    string.IsNullOrWhiteSpace(merchantContains) ? (object)DBNull.Value : merchantContains.Trim();

                cmd.Parameters.Add("@AmountMin", SqlDbType.Decimal).Value = (object)amountMin ?? DBNull.Value;
                cmd.Parameters.Add("@AmountMax", SqlDbType.Decimal).Value = (object)amountMax ?? DBNull.Value;

                cmd.Parameters.Add("@DateFrom", SqlDbType.Date).Value = (object)dateFrom ?? DBNull.Value;
                cmd.Parameters.Add("@DateTo", SqlDbType.Date).Value = (object)dateTo ?? DBNull.Value;

                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new TransactionRowDto
                        {
                            TransactionID = r.GetInt32(0),
                            Category = r.GetString(1),
                            Merchant = r.GetString(2),
                            Amount = r.GetDecimal(3),
                            Date = r.GetDateTime(4),
                            Wallet = r.GetString(5)
                        });
                    }
                }
            }

            return list;
        }

        // Backwards-compatible overload (if you still call old signature elsewhere)
        public List<TransactionRowDto> GetTransactions(int userId, int? month, bool importedOnly)
        {
            return GetTransactions(
                userId, month, importedOnly,
                walletAccountId: null,
                categoryId: null,
                merchantContains: null,
                amountMin: null,
                amountMax: null,
                dateFrom: null,
                dateTo: null
            );
        }

        // =========================
        // EDIT MODAL (LOAD)
        // =========================
        public TransactionEditDto GetTransactionForEdit(int userId, int transactionId)
        {
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
SELECT
    t.TransactionID,
    t.AccountID,
    t.CategoryID,
    t.Amount,
    t.TransactionType,
    t.TransactionDate,
    t.Merchant,
    t.Description,
    t.Source
FROM Transactions t
JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionID = @TransactionID
  AND a.UserID = @UserID;
";
                cmd.Parameters.Add("@TransactionID", SqlDbType.Int).Value = transactionId;
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;

                    return new TransactionEditDto
                    {
                        TransactionID = r.GetInt32(0),
                        AccountID = r.GetInt32(1),
                        CategoryID = r.GetInt32(2),
                        Amount = r.GetDecimal(3),
                        TransactionType = r.GetString(4),
                        TransactionDate = r.GetDateTime(5),
                        Merchant = r.IsDBNull(6) ? null : r.GetString(6),
                        Description = r.IsDBNull(7) ? null : r.GetString(7),
                        Source = r.IsDBNull(8) ? null : r.GetString(8)
                    };
                }
            }
        }

        // =========================
        // INSERT (MANUAL)
        // =========================
        public void InsertManualTransaction(int userId, TransactionEditDto dto)
        {
            if (dto == null) throw new ArgumentNullException(nameof(dto));

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
INSERT INTO Transactions
    (AccountID, CategoryID, Amount, TransactionType, TransactionDate, Merchant, Description, Source)
SELECT
    @AccountID, @CategoryID, @Amount, @TransactionType, @TransactionDate, @Merchant, @Description, 'MANUAL'
WHERE EXISTS (
    SELECT 1 FROM Accounts WHERE AccountID = @AccountID AND UserID = @UserID
);
";
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@AccountID", SqlDbType.Int).Value = dto.AccountID;
                cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value = dto.CategoryID;

                var pAmt = cmd.Parameters.Add("@Amount", SqlDbType.Decimal);
                pAmt.Precision = 18;
                pAmt.Scale = 2;
                pAmt.Value = dto.Amount;

                cmd.Parameters.Add("@TransactionType", SqlDbType.VarChar, 20).Value = dto.TransactionType;
                cmd.Parameters.Add("@TransactionDate", SqlDbType.Date).Value = dto.TransactionDate.Date;

                cmd.Parameters.Add("@Merchant", SqlDbType.NVarChar, 200).Value =
                    (object)dto.Merchant ?? DBNull.Value;

                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value =
                    (object)dto.Description ?? DBNull.Value;

                conn.Open();
                int affected = cmd.ExecuteNonQuery();
                if (affected == 0) throw new InvalidOperationException("Unable to add transaction (wallet not found for user).");
            }
        }

        // =========================
        // UPDATE
        // =========================
        public void UpdateTransaction(int userId, TransactionEditDto dto)
        {
            if (dto == null) throw new ArgumentNullException(nameof(dto));

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
UPDATE t
SET
    t.AccountID = @AccountID,
    t.CategoryID = @CategoryID,
    t.Amount = @Amount,
    t.TransactionType = @TransactionType,
    t.TransactionDate = @TransactionDate,
    t.Merchant = @Merchant,
    t.Description = @Description
FROM Transactions t
JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionID = @TransactionID
  AND a.UserID = @UserID;
";
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@TransactionID", SqlDbType.Int).Value = dto.TransactionID;
                cmd.Parameters.Add("@AccountID", SqlDbType.Int).Value = dto.AccountID;
                cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value = dto.CategoryID;

                var pAmt = cmd.Parameters.Add("@Amount", SqlDbType.Decimal);
                pAmt.Precision = 18;
                pAmt.Scale = 2;
                pAmt.Value = dto.Amount;

                cmd.Parameters.Add("@TransactionType", SqlDbType.VarChar, 20).Value = dto.TransactionType;
                cmd.Parameters.Add("@TransactionDate", SqlDbType.Date).Value = dto.TransactionDate.Date;

                cmd.Parameters.Add("@Merchant", SqlDbType.NVarChar, 200).Value =
                    (object)dto.Merchant ?? DBNull.Value;

                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value =
                    (object)dto.Description ?? DBNull.Value;

                conn.Open();
                int affected = cmd.ExecuteNonQuery();
                if (affected == 0) throw new InvalidOperationException("Update failed (transaction not found or not owned by user).");
            }
        }

        // =========================
        // DELETE (handles FK attachments)
        // =========================
        public void DeleteTransaction(int userId, int transactionId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1) Ensure ownership + delete attachments first (FK fix)
                        using (var cmdAtt = conn.CreateCommand())
                        {
                            cmdAtt.Transaction = tx;
                            cmdAtt.CommandText = @"
DELETE ta
FROM TransactionAttachments ta
JOIN Transactions t ON ta.TransactionID = t.TransactionID
JOIN Accounts a ON t.AccountID = a.AccountID
WHERE ta.TransactionID = @TransactionID
  AND a.UserID = @UserID;
";
                            cmdAtt.Parameters.Add("@TransactionID", SqlDbType.Int).Value = transactionId;
                            cmdAtt.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                            cmdAtt.ExecuteNonQuery();
                        }

                        // 2) Delete the transaction (ownership enforced)
                        using (var cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = @"
DELETE t
FROM Transactions t
JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionID = @TransactionID
  AND a.UserID = @UserID;
";
                            cmd.Parameters.Add("@TransactionID", SqlDbType.Int).Value = transactionId;
                            cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                            int affected = cmd.ExecuteNonQuery();
                            if (affected == 0)
                                throw new InvalidOperationException("Delete failed (transaction not found or not owned by user).");
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}


