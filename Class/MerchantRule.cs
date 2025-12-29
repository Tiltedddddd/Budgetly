namespace Budgetly.Class
{
    public class MerchantRule
    {
        public int RuleID { get; set; }
        public string MerchantKeyword { get; set; }
        public int CategoryID { get; set; }
        public int? UserID { get; set; }
    }
}
