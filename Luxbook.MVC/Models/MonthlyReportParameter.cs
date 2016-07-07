namespace Luxbook.MVC.Models
{
    using System;
    using Common;

    public class MonthlyReportParameter
    {
        public bool InternationalsOnly { get; set; }
        public Enums.RaceType RaceType { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool PaperTrades { get; set; }
    }
}