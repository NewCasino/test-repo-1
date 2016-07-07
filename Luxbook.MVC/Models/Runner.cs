using System;

namespace Luxbook.MVC.Models
{
    /// <summary>
    ///     %els the view VW_RUNNER_PRICES
    /// </summary>
    public class Runner
    {
        private decimal _pmDvp;
        private decimal _sdp;
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public int Runner_No { get; set; }
        public string Name { get; set; }


        /// <summary>
        ///     Returns the rounded DVP
        /// </summary>
        public decimal Pm_Dvp
        {
            get { return FixDividendPricing(_pmDvp); }
            set { _pmDvp = value; }
        }

        /// <summary>
        ///     Best of Best fixed win
        /// </summary>
        public decimal Fx_Bob { get; set; }

        /// <summary>
        ///     Luxbet Fixed odds , LUX column in the Maker page
        /// </summary>
        public decimal Lxb_Fw { get; set; }

        public decimal Qld_Fw { get; set; }

        /// <summary>
        ///     TAB fixed win dividend
        /// </summary>
        public decimal Vic_Fw { get; set; }


        public decimal BFR_FW_L1 { get; set; }

        /// <summary>
        ///     Returns the rounded value
        /// </summary>
        public decimal SDP
        {
            get { return FixDividendPricing(_sdp); }
            set { _sdp = value; }
        }

        public decimal BFR_WAP { get; set; }
        
        public int? SDP_ADJ { get; set; } 
        public int? SDP_ADJ_TAB { get; set; } 

        /// <summary>
        ///     Special sauce to round SDP and DVP into normalized values
        /// </summary>
        /// <param name="dividend"></param>
        /// <returns></returns>
        private decimal FixDividendPricing(decimal dividend)
        {
            var result = Math.Floor(dividend*100);

            if (result <= 101)
            {
                result = 101;
            }
            else if (result <= 130)
            {
                result -= (result%2);
            }
            else if (result <= 250)
            {
                result -= (result%5);
            }
            else if (result <= 270)
            {
                result -= (result%10);
            }
            else if (result < 275)
            {
                result = 270;
            }
            else if (result < 280)
            {
                result = 275;
            }
            else if (result <= 400)
            {
                result -= (result%10);
            }
            else if (result <= 500)
            {
                result -= (result%20);
            }
            else if (result <= 1000)
            {
                result -= (result%50);
            }
            else if (result <= 2100)
            {
                result -= (result%100);
            }
            else if (result < 2600)
            {
                result = 2100;
            }
            else if (result < 3100)
            {
                result = 2600;
            }
            else if (result < 4100)
            {
                result = 3100;
            }
            else if (result < 5100)
            {
                result = 4100;
            }
            else if (result < 6100)
            {
                result = 5100;
            }
            else if (result < 6700)
            {
                result = 6100;
            }
            else if (result < 8100)
            {
                result = 6700;
            }
            else if (result < 10100)
            {
                result = 8100;
            }
            else if (result < 15100)
            {
                result = 10100;
            }
            else if (result < 20100)
            {
                result = 15100;
            }
            else if (result < 25100)
            {
                result = 20100;
            }
            else if (result < 30100)
            {
                result = 25100;
            }
            else if (result < 33100)
            {
                result = 30100;
            }
            else if (result < 40100)
            {
                result = 33100;
            }
            else if (result < 50100)
            {
                result = 40100;
            }
            else if (result < 100100)
            {
                result = 50100;
            }
            else if (result >= 100100)
            {
                result = 100100;
            }

            result = result/100;


            return result;
        }
    }
}