using System;

namespace Budgetly.Class
{
    public class Budget
    {
        public int BudgetID { get; set; }
        public int UserID { get; set; }
        public string YearMonth { get; set; } // "YYYY-MM"
        public decimal TotalAmount { get; set; }
        public DateTime CreatedOn { get; set; }
    }
}
