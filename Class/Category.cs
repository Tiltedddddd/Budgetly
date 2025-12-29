namespace Budgetly.Class
{
    public class Category
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; }
        public decimal EcoWeight { get; set; }
        public bool IsEssential { get; set; }
        public string IconPath { get; set; }
    }
}
