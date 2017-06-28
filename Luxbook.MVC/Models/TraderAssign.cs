using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class TraderAssign
    {
        public int Trader_Assign_Id { get; set; }
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Assignment_Date { get; set; }
        public bool Lux_Trader { get; set; }        
        public bool Tab_Trader { get; set; }
        public bool Sun_Trader { get; set; }
        public bool Lux_Ma { get; set; }        
        public bool Tab_Ma { get; set; }
        public bool Sun_Ma { get; set; }
        /// <summary>
        /// Trader username
        /// </summary>
        public string LID { get; set; }

    }
}