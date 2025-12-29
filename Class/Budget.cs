using System;

namespace Budgetly.Class
{
    public class Budget
    {
        public int BudgetID { get; set; }
        public int UserID { get; set; }
        public string YearMonth { get; set; }
        public string Title { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime CreatedOn { get; set; }
    }
}
