namespace Budgetly.Class
{
    public class UserProfile
    {
        public int ProfileID { get; set; }
        public int UserID { get; set; }
        public string DisplayName { get; set; }
        public string ProfileImagePath { get; set; }
        public string ThemePreference { get; set; }
        public bool NotificationEnabled { get; set; }
    }
}
