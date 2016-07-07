using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    using Common;

    public class ReportParameters
    {
        public Enums.RaceType RaceType { get; set; }

        public bool InternationalOnly { get; set; }
    }
}