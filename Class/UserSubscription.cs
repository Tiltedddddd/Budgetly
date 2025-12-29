using System;

namespace Budgetly.Class
{
    public class UserSubscription
    {
        public int UserSubscriptionID { get; set; }
        public int UserID { get; set; }
        public int SubscriptionID { get; set; }
        public bool IsActive { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
