using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models.DTOs
{
    public class DashboardTransactionDto
    {
        public int id { get; set; }
        public string merchant { get; set; }
        public string category { get; set; }
        public decimal amount { get; set; } 
        public string type { get; set; } // INCOME / EXPENSE
        public string icon { get; set; }
        public DateTime date { get; set; }

    }
}