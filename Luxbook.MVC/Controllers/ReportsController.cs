namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Diagnostics;
    using System.Linq;
    using System.Web.Mvc;
    using ModelBuilders;
    using Models;
    using Services;
    using ViewModels.Reports;

    public partial class ReportsController : Controller
    {
        private readonly IReportService _reportService;
        private readonly ReportModelBuilder _reportModelBuilder;
        private readonly IMeetingService _meetingService;
        private readonly ITraderService _traderService;
        private readonly ISystemService _systemService;
        private readonly IEventService _eventService;

        public ReportsController(IReportService reportService, ReportModelBuilder reportModelBuilder,
            IMeetingService meetingService, ITraderService traderService, ISystemService systemService,
            IEventService eventService)
        {
            _reportService = reportService;
            _reportModelBuilder = reportModelBuilder;
            _meetingService = meetingService;
            _traderService = traderService;
            _systemService = systemService;
            _eventService = eventService;
        }

        private static readonly Random Random = new Random();

        // GET: Reports
        public virtual ActionResult Monthly(MonthlyReportParameter parameter)
        {
            // Get trades at the start of 3 months ago till today if date range not specified
            if (!parameter.StartDate.HasValue || !parameter.EndDate.HasValue)
            {
                var today = DateTime.Today.AddDays(1).AddMilliseconds(-1); // get the end of today
                var threeMonths = today.AddMonths(-2);

                parameter.StartDate = new DateTime(threeMonths.Year, threeMonths.Month, 1);
                parameter.EndDate = today;
            }


            var trades = _reportService.GetTradings(parameter.StartDate.Value, parameter.EndDate.Value
                , parameter.RaceType, parameter.InternationalsOnly, parameter.PaperTrades);

            var viewModel = _reportModelBuilder.CreateReportsMonthlyViewModel(parameter, trades);

            #region test data

            //viewModel.RaceTypes = "Harness";
            //viewModel.Date = DateTime.Today;
            //viewModel.ReportsMonthly = new List<List<DailyReport>>();
            //var feb = new List<DailyReport>();
            //for (int i = 0; i < 28; i++)
            //{
            //    var dailyReport = new DailyReport
            //    {
            //        ReportDate = DateTime.Parse("2015-02-01").AddDays(i)
            //    };
            //    dailyReport.Trade = Random.Next(5000, 30000);

            //    dailyReport.Return = ((Random.Next(0, 100) * NegativeOrPositive()) / 100m) * dailyReport.Trade.Value;
            //    feb.Add(dailyReport);
            //}

            //viewModel.ReportsMonthly.Add(feb);

            //var mar = new List<DailyReport>();
            //for (int i = 0; i < 31; i++)
            //{
            //    var dailyReport = new DailyReport
            //    {
            //        ReportDate = DateTime.Parse("2015-03-01").AddDays(i)
            //    };
            //    dailyReport.Trade = Random.Next(5000, 30000);

            //    dailyReport.Return = ((Random.Next(0, 100) * NegativeOrPositive()) / 100m) * dailyReport.Trade.Value;

            //    mar.Add(dailyReport);
            //}

            //viewModel.ReportsMonthly.Add(mar);

            //var apr = new List<DailyReport>();
            //for (int i = 0; i < 30; i++)
            //{
            //    var dailyReport = new DailyReport
            //    {
            //        ReportDate = DateTime.Parse("2015-04-01").AddDays(i)
            //    };
            //    dailyReport.Trade = Random.Next(5000, 30000);

            //    dailyReport.Return = ((Random.Next(0, 100) * NegativeOrPositive()) / 100m) * dailyReport.Trade.Value;
            //    apr.Add(dailyReport);
            //}

            //viewModel.ReportsMonthly.Add(apr);

            #endregion

            return View(viewModel);
        }

        public virtual ActionResult Pool(PoolReportParameters parameters)
        {
            var traders = _traderService.GetTraders();
            var observations = _systemService.GetSystemEnums("OBSV");
            var meetingDates = _meetingService.GetAllMeetingDates();

            ReportsPoolViewModel viewModel = new ReportsPoolViewModel();
            if (parameters.Date.HasValue)
            {

                var events = _eventService.GetAllEvents(parameters.Date.Value, parameters.InternationalsOnly, parameters.RaceType);

                var trades = _reportService.GetTradingSummaries(events.Select(x => x.Meeting_Id).Distinct(), parameters.PaperTrades);
                viewModel = _reportModelBuilder.CreateReportsPoolViewModel(parameters, trades, traders, observations,
                    events);
            } else
            {
                viewModel.RaceType = parameters.RaceType;
            }
            viewModel.MeetingDates = _reportModelBuilder.CreateMeetingDatesViewModel(meetingDates);

            viewModel.MeetingDates.UrlFormat = Url.Action(Mvc.Reports.Pool()) + "?date={0}&raceType=" + viewModel.RaceType + "&internationalsOnly=" + parameters.InternationalsOnly;
            #region test data

            //var meetings = new List<ReportsPoolViewModel.Meeting>();

            //for (int i = 0; i < 6; i++)
            //{
            //    var meeting = new ReportsPoolViewModel.Meeting();
            //    meeting.Name = "RANDOM MEETING " + i;
            //    meeting.CountryCode = i%2 > 0 ? "AU" : "NZ";
            //    meeting.RaceType = Enums.RaceType.Harness;
            //    meeting.RaceTypeCode = "H";
            //    meeting.Races = new List<ReportsPoolViewModel.Race>();

            //    for (int j = 0; j < Random.Next(4, 14); j++)
            //    {
            //        var race = new ReportsPoolViewModel.Race();


            //        race.Comments = j%3 == 0 ? "Random comment " + Random.Next(10, 10000) : null;
            //        race.Number = j + 1;
            //        race.RaceStatus = (Enums.RaceStatus) Random.Next(0, 7);
            //        race.Totes = new List<ReportsPoolViewModel.Tote>();
            //        for (int toteIndex = 0; toteIndex < 3; toteIndex++)
            //        {
            //            var tote = new ReportsPoolViewModel.Tote();

            //            tote.Name = "something";
            //            tote.Trade = Random.Next(0, 10000);
            //            tote.Rebate = tote.Trade.Value*0.02m;
            //            tote.Payout = Random.Next(0, (int) (tote.Trade*2));
            //            race.Totes.Add(tote);
            //        }

            //        meeting.Races.Add(race);
            //    }


            //    meetings.Add(meeting);
            //}
            //viewModel.Meetings = meetings;

            #endregion

            return View(viewModel);
        }


        public virtual ActionResult Type(PoolReportParameters parameters)
        {
            var traders = _traderService.GetTraders();
            var observations = _systemService.GetSystemEnums("OBSV");
            var meetingDates = _meetingService.GetAllMeetingDates();

            ReportsTypeViewModel viewModel = new ReportsTypeViewModel();
            if (parameters.Date.HasValue)
            {
                var events = _eventService.GetAllEvents(parameters.Date.Value, parameters.InternationalsOnly, parameters.RaceType);

                var trades = _reportService.GetTradingBetTypeSummaries(events.Select(x => x.Meeting_Id).Distinct(), parameters.PaperTrades);
                viewModel = _reportModelBuilder.CreateReportsTypeViewModel(parameters, trades, traders, observations,
                    events);
            }
            else
            {
                viewModel.RaceType = parameters.RaceType;
            }

            viewModel.MeetingDates = _reportModelBuilder.CreateMeetingDatesViewModel(meetingDates);

            viewModel.MeetingDates.UrlFormat =  Url.Action(Mvc.Reports.Type()) + "?date={0}&raceType=" + viewModel.RaceType + "&internationalsOnly=" + parameters.InternationalsOnly;

            return View(viewModel);
        }
        public int NegativeOrPositive()
        {
            return Random.Next(0, 2) * 2 - 1;
        }
    }
}