namespace Budgetly.Class
{
    public class Income
    {
        public int IncomeID { get; set; }
        public int UserID { get; set; }
        public int AccountID { get; set; }
        public string YearMonth { get; set; }
        public decimal Amount { get; set; }
        public string Source { get; set; }
    }
}
