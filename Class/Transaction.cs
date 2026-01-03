using System;

namespace Budgetly.Class
{
    public class Transaction
    {
        public int TransactionID { get; set; }
        public int AccountID { get; set; }
        public int CategoryID { get; set; }
        public decimal Amount { get; set; }
        public string TransactionType { get; set; } // e.g. "EXPENSE" or "INCOME"
        public DateTime TransactionDate { get; set; }
        public string Merchant { get; set; }
        public string Description { get; set; }
        public string Source { get; set; } // e.g. "MANUAL", "GMAIL", "IMPORT"
    }
}
