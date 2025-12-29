namespace Budgetly.Class
{
    public class BudgetEnvelope
    {
        public int EnvelopeID { get; set; }
        public int BudgetID { get; set; }
        public int CategoryID { get; set; }
        public decimal MonthlyLimit { get; set; }
    }
}
