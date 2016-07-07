using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    using Common;

    public class PoolReportParameters
    {
        public DateTime? Date { get; set; }
        public Enums.RaceType RaceType { get; set; }
        public bool InternationalsOnly { get; set; }
        public bool PaperTrades { get; set; }

    }
}