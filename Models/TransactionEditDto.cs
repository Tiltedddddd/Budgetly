using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models
{
    public class TransactionEditDto
    {
        public int TransactionID { get; set; }

        public int AccountID { get; set; }
        public int CategoryID { get; set; }

        public decimal Amount { get; set; }
        public string TransactionType { get; set; }
        public DateTime TransactionDate { get; set; }

        public string Merchant {  get; set; }
        public string Description { get; set; }

        public string Source { get; set; }

    }
}