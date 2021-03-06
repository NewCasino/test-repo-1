﻿using System;
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

        public string TraderName { get; set; }

        /// <summary>
        /// Returns the assignment string (e.g. this trader has been assigned these roles) 
        /// that can be used as a hash to compare against assignments in other events
        /// </summary>
        /// <returns></returns>
        public string GetAssignmentString()
        {
            return $"{LID}~{Lux_Trader}~{Lux_Ma}~{Tab_Trader}~{Tab_Ma}~{Sun_Ma}~{Sun_Trader}";
        }
    }
}