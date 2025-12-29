using System;

namespace Budgetly.Class
{
    public class AccountImage
    {
        public int ImageID { get; set; }
        public int AccountID { get; set; }
        public string ImagePath { get; set; }
        public DateTime UploadedOn { get; set; }
    }
}
