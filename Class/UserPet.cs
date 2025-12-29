using System;

namespace Budgetly.Class
{
    public class UserPet
    {
        public int UserPetID { get; set; }
        public int UserID { get; set; }
        public int PetID { get; set; }
        public int XP { get; set; }
        public int EcoScore { get; set; }
        public DateTime LastActiveDate { get; set; }
        public int InactiveDays { get; set; }
        public string PetStatus { get; set; }
        public bool IsPetSubscribed { get; set; }
    }
}
