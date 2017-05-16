using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class TraderAssign
    {
        public int Trader_Assign_Id { get; set; }
        public DateTime Meeting_Date { get; set; }
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Assigned_Date { get; set; }
        public string Lux_Trader { get; set; }        
        public string Tab_Trader { get; set; }
        public string Sun_Trader { get; set; }
        public string Lux_Ma { get; set; }        
        public string Tab_Ma { get; set; }
        public string Sun_Ma { get; set; }

    }
}