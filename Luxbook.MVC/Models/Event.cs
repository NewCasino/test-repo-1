using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class Event
    {
        public Event()
        {
        }

        public string Name { get; set; }
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Start_Time { get; set; }
        public string Country { get; set; }
        public string RaceTypeCode { get; set; }
        public string Status { get; set; }

        public string Venue { get; set; }

        /// <summary>
        ///     Minutes difference from jump time
        ///     Negative means already jumped, positive means future event
        /// </summary>
        public int M2r { get; set; }

        public int NoLxb { get; set; }
        public int FxCount { get; set; }

        public string Trader { get; set; }

        /// <summary>
        /// Trader observation
        /// </summary>
        public string Obsv { get; set; }
        public string Comment { get; set; }

        /// <summary>
        /// Mapped from TAB_SELL_CODE
        /// </summary>
        public string SellCode { get; set; }
    }
}