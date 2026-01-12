using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Budgetly.Models.DTOs
{
    public class GoalSummaryDto
    {
        public string YearMonth { get; set; }
        public decimal MonthlyIncome { get; set; }
        public decimal TotalBudgetLimit { get; set; }
        public List<GoalEnvelopeDto> Envelopes { get; set; }
    }
}