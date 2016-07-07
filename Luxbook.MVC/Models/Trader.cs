namespace Luxbook.MVC.Models
{
    using System.Collections.Generic;

    public class Trader
    {
        public string Name { get; set; }

        /// <summary>
        ///     maps to LID in the db
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        ///     Maps to LVL in the db
        /// </summary>
        public string Level { get; set; }

        /// <summary>
        ///    Maps to Game
        /// </summary>
        public string GameTypes { get; set; }

        public string Continents { get; set; }

        public decimal? MinimumPercentage { get; set; }

        /// <summary>
        /// The minimum time in minutes a race can start before it is filtered out 
        /// </summary>
        public int? RaceStartTimeFilter { get; set; }

        /// <summary>
        /// The maximum time in minutes a race can start before it is filtered out 
        /// </summary>
        public int? RaceEndStartTimeFilter { get; set; }

        public bool Operator { get; set; }

    }
}