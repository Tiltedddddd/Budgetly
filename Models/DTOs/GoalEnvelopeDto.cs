using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models.DTOs
{
    public class GoalEnvelopeDto
    {
        public int EnvelopeId { get; set; }
        public string CategoryName { get; set; }
        public decimal MonthlyLimit { get; set; }
        public decimal SpentAmount { get; set; }
        public decimal RemainingAmount { get; set; }
    }
}