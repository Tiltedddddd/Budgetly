using System;

namespace Budgetly.Class
{
    public class Account
    {
        public int AccountID { get; set; }
        public int UserID { get; set; }
        public string AccountName { get; set; }
        public string AccountType { get; set; }
        public decimal Balance { get; set; }
        public bool IsGmailSyncEnabled { get; set; }
        public DateTime? LastSyncDate { get; set; }
    }
}
