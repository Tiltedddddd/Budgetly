using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models.DTOs
{
    public class DashboardAccountDto
    {
        public int AccountId { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public decimal Balance { get; set; }
        public bool IsDefault { get; set; }
    }

}