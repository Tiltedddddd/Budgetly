using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models
{
    public class TransactionRowDto
    {
        public int TransactionID { get; set; }
        public string Category { get; set; }
        public string Merchant {  get; set; }
        public decimal Amount { get; set; }
        public DateTime Date {  get; set; }
        public string Wallet {  get; set; }

    }
}