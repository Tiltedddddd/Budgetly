using System;

namespace Budgetly.Class
{
    public class BudgetProgress
    {
        public int ProgressID { get; set; }
        public int BudgetID { get; set; }
        public int CategoryID { get; set; }
        public decimal SpentAmount { get; set; }
        public decimal RemainingAmount { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}
