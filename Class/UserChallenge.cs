using System;

namespace Budgetly.Class
{
    public class UserChallenge
    {
        public int UserChallengeID { get; set; }
        public int UserID { get; set; }
        public int ChallengeID { get; set; }
        public decimal ProgressAmount { get; set; }
        public bool IsCompleted { get; set; }
        public DateTime? CompletedOn { get; set; }
    }
}
