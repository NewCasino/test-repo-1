using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class Bettekk
    {
        /// <summary>
        /// Octs code
        /// </summary>
        public string Code { get; set; }
        /// <summary>
        /// Race type
        /// </summary>
        public string Type { get; set; }
        public string Venue { get; set; }
        public string Betfair { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public string GCode { get; set; }
        public string GTFav { get; set; }
        public string GtxCode { get; set; }
        public string Alt_Venue { get; set; }
        public int? Rank { get; set; }
    }
}