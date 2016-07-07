using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class RunnerLiability
    {
        public string Venue { get; set; }
        public string Runner_Name { get; set; }

        public decimal Liability { get; set; }
        public string Bet_Type { get; set; }

        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        
        public int Runner_No { get; set; }

        public DateTime Start_Time { get; set; }

        public string Meeting_Type { get; set; }
    }
}