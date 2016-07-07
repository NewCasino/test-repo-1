namespace Luxbook.MVC.ViewModels.Reports
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using Common;

    public class ReportsPoolViewModel
    {
        public ReportsPoolViewModel()
        {
            Meetings = new List<Meeting>();
        }

        public MeetingDatesViewModel MeetingDates { get; set; }

        public Enums.RaceType RaceType { get; set; }
        public DateTime MeetingDate { get; set; }

        public IEnumerable<SelectListItem> Observations { get; set; }
        public IEnumerable<SelectListItem> Traders { get; set; }

        public List<Meeting> Meetings { get; set; }

        public decimal NswToteTrades
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.NswTotes).Sum(x => x.Trade);
            }
        }
        public decimal NswToteRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.NswTotes).Sum(x => x.Rebate); ;
            }
        }
        public decimal NswTotePayout
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.NswTotes).Sum(x => x.Payout);
            }
        }

        public decimal NswToteProfit
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.NswTotes).Sum(x => x.Profit.GetValueOrDefault());
            }
        }

        public decimal NswToteProfitWithoutRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.NswTotes).Sum(x => x.ProfitWithoutRebate.GetValueOrDefault());
            }
        }

        public decimal StabToteTrades
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.StabTotes).Sum(x => x.Trade);
            }
        }
        public decimal StabToteRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.StabTotes).Sum(x => x.Rebate);
            }
        }
        public decimal StabTotePayout
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.StabTotes).Sum(x => x.Payout);
            }
        }

        public decimal StabToteProfit
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.StabTotes).Sum(x => x.Profit.GetValueOrDefault());
            }
        }

        public decimal StabToteProfitWithoutRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.StabTotes).Sum(x => x.ProfitWithoutRebate.GetValueOrDefault());
            }
        }

        public decimal QldToteTrades
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.QldTotes).Sum(x => x.Trade);
            }
        }
        public decimal QldToteRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.QldTotes).Sum(x => x.Rebate);
            }
        }
        public decimal QldTotePayout
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.QldTotes).Sum(x => x.Payout);
            }
        }

        public decimal QldToteProfit
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.QldTotes).Sum(x => x.Profit.GetValueOrDefault());
            }
        }

        public decimal QldToteProfitWithoutRebates
        {
            get
            {
                return Meetings.SelectMany(x => x.Races).Select(x => x.QldTotes).Sum(x => x.ProfitWithoutRebate.GetValueOrDefault());
            }
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
                NswTotes = new Tote();
                StabTotes = new Tote();
                QldTotes = new Tote();
            }
            public int Number { get; set; }
            public string Trader { get; set; }
            public string Observation { get; set; }
            public string Comments { get; set; }
            public Enums.RaceStatus RaceStatus { get; set; }

            public Tote NswTotes { get; set; }
            public Tote StabTotes { get; set; }
            public Tote QldTotes { get; set; }

        }

        public class Tote
        {
            public string Name { get; set; }
            public decimal Trade { get; set; }
            public decimal Rebate { get; set; }
            public decimal Payout { get; set; }

            public decimal? Profit
            {
                get
                {
                    return Payout + Rebate - Trade;
                }
            }

            public decimal? ProfitWithoutRebate
            {
                get
                {
                    return Payout - Trade;
                }
            }
        }
    }
}