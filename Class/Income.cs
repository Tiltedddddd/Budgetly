namespace Budgetly.Class
{
    public class Income
    {
        public int IncomeID { get; set; }
        public int UserID { get; set; }
        public int? AccountID { get; set; }  // nullable if income not tied to a wallet
        public string YearMonth { get; set; } // "YYYY-MM"
        public decimal Amount { get; set; }
        public string Source { get; set; }
    }
}
