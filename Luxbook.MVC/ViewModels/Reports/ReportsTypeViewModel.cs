namespace Luxbook.MVC.ViewModels.Reports
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using Common;

    public class ReportsTypeViewModel
    {

        public ReportsTypeViewModel()
        {
            Meetings = new List<Meeting>();
        }
        public MeetingDatesViewModel MeetingDates { get; set; }

        public Enums.RaceType RaceType { get; set; }
        public DateTime MeetingDate { get; set; }

        public IEnumerable<SelectListItem> Observations { get; set; }
        public IEnumerable<SelectListItem> Traders { get; set; }

        public List<Meeting> Meetings { get; set; }

        public decimal WinPlaceTrades
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.WinPlace).Sum(x => x.Trade); }
        }

        public decimal WinPlacePayout
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.WinPlace).Sum(x => x.Payout); }
        }

        public decimal WinPlaceRebates
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.WinPlace).Sum(x => x.Rebate); }
        }

        public decimal WinPlaceProfit
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.WinPlace).Sum(x => x.Profit); }
        }

        public decimal OverallTrades
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Overall).Sum(x => x.Trade); }
        }

        public decimal OverallPayout
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Overall).Sum(x => x.Payout); }
        }

        public decimal OverallRebates
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Overall).Sum(x => x.Rebate); }
        }

        public decimal OverallProfit
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Overall).Sum(x => x.Profit); }
        }

        public decimal ExoticsTrades
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Exotics).Sum(x => x.Trade); }
        }

        public decimal ExoticsPayout
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Exotics).Sum(x => x.Payout); }
        }

        public decimal ExoticsRebates
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Exotics).Sum(x => x.Rebate); }
        }

        public decimal ExoticsProfit
        {
            get { return Meetings.SelectMany(x => x.Races).Select(x => x.Exotics).Sum(x => x.Profit); }
        }

        public class Meeting
        {
            public Meeting()
            {
                Races = new List<Race>();
            }

            public string Name { get; set; }
            public Enums.RaceType RaceType { get; set; }
            public string RaceTypeCode { get; set; }
            public List<Race> Races { get; set; }
            public string CountryCode { get; set; }
            public int MeetingId { get; set; }
        }

        public class Race
        {
            public Race()
            {
                WinPlace = new BetType();
                Exotics = new BetType();
                Overall = new BetType();
            }

            public int Number { get; set; }
            public string Trader { get; set; }
            public string Observation { get; set; }
            public string Comments { get; set; }
            public Enums.RaceStatus RaceStatus { get; set; }

            public BetType WinPlace { get; set; }
            public BetType Exotics { get; set; }

            public BetType Overall { get; set; }
        }

        public class BetType
        {
            public string Name { get; set; }
            public decimal Trade { get; set; }
            public decimal Rebate { get; set; }
            public decimal Payout { get; set; }

            public decimal Profit
            {
                get { return Payout - Trade + Rebate; }
            }
        }
    }
}