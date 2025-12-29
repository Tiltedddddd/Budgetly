using System;

namespace Budgetly.Class
{
    public class GmailTransactionTracker
    {
        public int GmailID { get; set; }
        public int UserID { get; set; }
        public string EmailMessageID { get; set; }
        public string ParsedMerchant { get; set; }
        public decimal? ParsedAmount { get; set; }
        public DateTime? ParsedDate { get; set; }
        public int? LinkedTransactionID { get; set; }
        public string Status { get; set; }
    }
}
