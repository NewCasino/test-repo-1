using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.ViewModels.Reports
{
    public class ReportsMonthlyViewModel
    {
        public string RaceTypes { get; set; }
        public DateTime Date { get; set; }
        public List<ReportGroup> ReportsMonthly { get; set; }
    }

    public class ReportGroup
    {
        public ReportGroup()
        {
            Reports = new List<DailyReport>();
        }
        public DateTime StartDateOfReports { get; set; }
        public List<DailyReport> Reports { get; set; }
    }

    public class DailyReport
    {
        public DateTime ReportDate { get; set; }
        public decimal? Trade { get; set; }

        public decimal? Profit
        {
            get
            {
                if (Trade.HasValue)
                {
                    return Return.GetValueOrDefault() - Trade.Value;
                }

                return null;
            }
        }

        public decimal? Rebates { get; set; }

        public decimal? Return { get; set; }
        public decimal? Yield
        {
            get
            {
                if (Trade.GetValueOrDefault() == 0)
                {
                    return 0;
                }

                return Profit / Trade;
            }
        }
    }
}