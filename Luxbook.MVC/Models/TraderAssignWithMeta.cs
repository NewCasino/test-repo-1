using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class TraderAssignWithMeta : TraderAssign
    {
        public DateTime Meeting_Date { get; set; }
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        /// <summary>
        /// event name
        /// </summary>
        public string Name { get; set; }

        public DateTime Start_Time { get; set; }
        public string Country { get; set; }
        public string Type { get; set; }
        public string Region { get; set; }
        public string Venue { get; set; }        

        public int EventsInMeeting { get; set; }
    }
}