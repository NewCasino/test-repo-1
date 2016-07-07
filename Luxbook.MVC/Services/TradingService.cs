using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Services
{
    using DigitalApi.Models;

    /// <summary>
    /// Deals with actual trades
    /// </summary>
    public class TradingService
    {
        /// <summary>
        /// Convert the gigantic batch bet string into individual bet strings
        /// </summary>
        /// <param name="batchBet"></param>
        /// <returns></returns>
        public List<string> GetBetStrings(string batchBet)
        {
            return null;
        }

        /// <summary>
        /// Convert strings of individual bets into an actual Bet list
        /// </summary>
        /// <param name="betStrings"></param>
        /// <returns></returns>
        public List<Bet> ConvertToBets(List<string> betStrings)
        {
            return null;
        }
    }
}