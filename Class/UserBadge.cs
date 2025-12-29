using System;

namespace Budgetly.Class
{
    public class UserBadge
    {
        public int UserBadgeID { get; set; }
        public int UserID { get; set; }
        public int BadgeID { get; set; }
        public DateTime EarnedOn { get; set; }
    }
}
