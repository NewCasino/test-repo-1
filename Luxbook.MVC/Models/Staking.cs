using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class Staking
    {
        private readonly List<string> _poolIdLookup = new List<string>() { "Win", "Place", "Exacta", "Quinella", "Duet", "Trifecta", "Trio", "First 4" , "Special" };
        /// <summary>
        /// Market to trade e.g. NSW, VIC
        /// </summary>
        public string Market { get; set; }

        /// <summary>
        /// Id of the pool (e.g. win, place, exacta)
        /// </summary>
        public int Pool_Id { get; set; }

        public string PoolName
        {
            get { return _poolIdLookup[Pool_Id]; }
        }
        /// <summary>
        /// Determines if the pool is active
        /// </summary>
        public bool Pool_Tck { get; set; }

        // Minimum expression %. 
        public decimal Exp_Min { get; set; }

        /// <summary>
        /// Determine if the expression limit is active
        /// </summary>
        public bool Exp_Tck { get; set; }

        /// <summary>
        /// Maximum takeout amount
        /// </summary>
        public decimal Tko_Amt { get; set; }

        /// <summary>
        /// Takeout percentage of pool?
        /// </summary>
        public decimal Tko_Pct { get; set; }

        /// <summary>
        /// Whether takeout setting is active maybe?
        /// </summary>
        public bool Tko_Tck { get; set; }

        /// <summary>
        /// Whether this applies when the venue is AU or not
        /// </summary>
        public bool Internationals { get; set; }

        /// <summary>
        /// Racing, Harness, Greyhounds
        /// </summary>
        public string Race_Type { get; set; }

        public int Staking_Id { get; set; }
    }
}