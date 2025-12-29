namespace Budgetly.Class
{
    public class Challenge
    {
        public int ChallengeID { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal TargetAmount { get; set; }
        public int? CategoryID { get; set; }
        public int XPReward { get; set; }
        public bool IsSystemGenerated { get; set; }
    }
}
