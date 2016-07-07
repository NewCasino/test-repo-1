using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    using Common;

    public class EventTrading
    {
        public decimal Return { get; set; }
        public decimal BetAmount { get; set; }
        public DateTime DateCreated { get; set; }
        public Enums.BetType BetType { get; set; }

        public string RaceType { get; set; }

        public int MeetingId { get; set; }
        public int EventNumber { get; set; }
        public decimal Rebate { get; set; }

        public Trading.Common.Enums.Jurisdiction Jurisdiction { get; set; }
        public string Agency { get; set; }

        public DateTime DayCreated
        {
            get { return DateCreated.Date; }
        }

        public DateTime MonthCreated
        {
            get { return new DateTime(DateCreated.Year, DateCreated.Month, 1); }
        }
    }
}