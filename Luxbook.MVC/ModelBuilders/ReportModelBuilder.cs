namespace Luxbook.MVC.ModelBuilders
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using AutoMapper;
    using Common;
    using Models;
    using Services;
    using ViewModels.Reports;

    public class ReportModelBuilder
    {
        private readonly ICodeService _codeService;

        public ReportModelBuilder(ICodeService codeService)
        {
            _codeService = codeService;
            Mapper.CreateMap<EventTrading, DailyReport>()
                .ForMember(dst => dst.Trade, opt => opt.MapFrom(src => src.BetAmount))
                .ForMember(dst => dst.ReportDate, opt => opt.MapFrom(src => src.DateCreated));

            Mapper.CreateMap<Event, ReportsPoolViewModel.Race>()
                .ForMember(dst => dst.Observation, opt => opt.MapFrom(src => src.Obsv))
                .ForMember(dst => dst.RaceStatus,
                    opt =>
                        opt.MapFrom(src => (Enums.RaceStatus)Enum.Parse(typeof(Enums.RaceStatus), src.Status, true)))
                .ForMember(dst => dst.Number, opt => opt.MapFrom(src => src.Event_No));

            Mapper.CreateMap<Event, ReportsTypeViewModel.Race>()
                .ForMember(dst => dst.Observation, opt => opt.MapFrom(src => src.Obsv))
                .ForMember(dst => dst.RaceStatus,
                    opt =>
                        opt.MapFrom(src => (Enums.RaceStatus)Enum.Parse(typeof(Enums.RaceStatus), src.Status, true)))
                .ForMember(dst => dst.Number, opt => opt.MapFrom(src => src.Event_No));
        }

        public ReportsMonthlyViewModel CreateReportsMonthlyViewModel(MonthlyReportParameter parameter,
            List<EventTrading> trades)
        {
            var viewModel = new ReportsMonthlyViewModel { ReportsMonthly = new List<ReportGroup>() };

            viewModel.RaceTypes = parameter.RaceType.ToString();
            viewModel.Date = DateTime.Now;

            // First let's create the groups of months
            var start = parameter.StartDate.Value;
            var end = parameter.EndDate;
            var totalMonths = ((end.Value.Year - start.Year)*12) + end.Value.Month - start.Month;
            for (int i = 0; i <= totalMonths; i++)
            {
                var currentMonth = start.AddMonths(i);
                viewModel.ReportsMonthly.Add(new ReportGroup
                {
                    StartDateOfReports = new DateTime(currentMonth.Year, currentMonth.Month, 1)
                });
            }

            // Next group the trades by month
            var tradeMonths = trades.GroupBy(x => x.MonthCreated);

            // go through each month group and calculate totals for the days and add them in
            foreach (var tradeMonth in tradeMonths)
            {
                var reportGroup = viewModel.ReportsMonthly.First(x => x.StartDateOfReports == tradeMonth.Key);

                foreach (var tradeDay in tradeMonth.GroupBy(x => x.DayCreated))
                {
                    var dailyReport = new DailyReport();

                    dailyReport.ReportDate = tradeDay.Key;
                    dailyReport.Trade = tradeDay.Sum(x => x.BetAmount);
                    dailyReport.Return = tradeDay.Sum(x => x.Return);
                    dailyReport.Rebates = tradeDay.Sum(x => x.Rebate) / 100;
                    reportGroup.Reports.Add(dailyReport);
                }
            }

            // We are going to add in days which have no trades so each report month group will have full days

            foreach (var reportGroup in viewModel.ReportsMonthly)
            {
                var lastDay = DateTime.DaysInMonth(reportGroup.StartDateOfReports.Year,
                    reportGroup.StartDateOfReports.Month);

                for (int day = 1; day <= lastDay; day++)
                {
                    if (reportGroup.Reports.All(x => x.ReportDate.Day != day))
                    {
                        reportGroup.Reports.Add(new DailyReport
                        {
                            ReportDate =
                                new DateTime(reportGroup.StartDateOfReports.Year, reportGroup.StartDateOfReports.Month,
                                    day)
                        });
                    }
                }
                // order all report group so the days are in correct order

                reportGroup.Reports = reportGroup.Reports.OrderBy(x => x.ReportDate).ToList();
            }


            return viewModel;
        }

        public MeetingDatesViewModel CreateMeetingDatesViewModel(List<Meeting> meetings)
        {
            var viewModel = new MeetingDatesViewModel();
            if (meetings == null)
            {
                return viewModel;
            }

            viewModel.Dates.AddRange(meetings.Where(x=>x.MeetingDate.HasValue).Select(x => x.MeetingDate.Value));

            return viewModel;
        }

        public ReportsTypeViewModel CreateReportsTypeViewModel(PoolReportParameters parameters,
            List<BetTypeSummary> eventTrades, List<Trader> traders, List<SystemEnum> observations,
            List<Event> events)
        {
            var viewModel = new ReportsTypeViewModel();
            viewModel.Observations = CreateObservations(observations);
            viewModel.Traders = CreateTraderList(traders);
            viewModel.RaceType = parameters.RaceType;
            viewModel.MeetingDate = parameters.Date.GetValueOrDefault();

            // find distinct meetings from events
            foreach (var meeting in events.GroupBy(x => x.Meeting_Id))
            {
                var firstRace = meeting.First();

                var viewMeeting = new ReportsTypeViewModel.Meeting()
                {
                    Name = firstRace.Venue,
                    CountryCode = firstRace.Country,
                    RaceTypeCode = firstRace.RaceTypeCode,
                    RaceType = _codeService.GetRaceTypeFromCode(firstRace.RaceTypeCode),
                    MeetingId = firstRace.Meeting_Id
                };

                viewModel.Meetings.Add(viewMeeting);
            }

            // get the races from meetings
            foreach (var meeting in viewModel.Meetings)
            {
                foreach (var meetingEvent in events.Where(x => x.Meeting_Id == meeting.MeetingId))
                {
                    var race = Mapper.Map<ReportsTypeViewModel.Race>(meetingEvent);

                    var summariesForRace = eventTrades.Where(x => x.MeetingId == meetingEvent.Meeting_Id && x.EventNumber == meetingEvent.Event_No);
                    var winPlaceBets = summariesForRace.Where(
                        x => x.BetType == Enums.BetType.Win || x.BetType == Enums.BetType.Place ||
                            x.BetType == Enums.BetType.WinAndPlace).ToList();

                    var exoticBets = summariesForRace.Where(
                        x => x.BetType != Enums.BetType.Win && x.BetType != Enums.BetType.Place &&
                            x.BetType != Enums.BetType.WinAndPlace).ToList();

                    race.WinPlace.Trade = winPlaceBets.Sum(x => x.BetAmount.GetValueOrDefault());
                    race.WinPlace.Rebate = winPlaceBets.Sum(x => x.Rebate.GetValueOrDefault());
                    race.WinPlace.Payout = winPlaceBets.Sum(x => x.Return.GetValueOrDefault());

                    race.Exotics.Trade = exoticBets.Sum(x => x.BetAmount.GetValueOrDefault());
                    race.Exotics.Rebate = exoticBets.Sum(x => x.Rebate.GetValueOrDefault());
                    race.Exotics.Payout = exoticBets.Sum(x => x.Return.GetValueOrDefault());

                    race.Overall.Trade = race.WinPlace.Trade + race.Exotics.Trade;
                    race.Overall.Rebate = race.WinPlace.Rebate + race.Exotics.Rebate;
                    race.Overall.Payout = race.WinPlace.Payout + race.Exotics.Payout;

                    meeting.Races.Add(race);
                }
            }

            return viewModel;
        }

        public ReportsPoolViewModel CreateReportsPoolViewModel(PoolReportParameters parameters,
            List<EventTradingSummary> eventTrades, List<Trader> traders, List<SystemEnum> observations, List<Event> events)
        {
            var viewModel = new ReportsPoolViewModel();

            viewModel.Observations = CreateObservations(observations);
            viewModel.Traders = CreateTraderList(traders);
            viewModel.RaceType = parameters.RaceType;
            viewModel.MeetingDate = parameters.Date.GetValueOrDefault();

            // find distinct meetings from events
            foreach (var meeting in events.GroupBy(x => x.Meeting_Id))
            {
                var firstRace = meeting.First();

                var viewMeeting = new ReportsPoolViewModel.Meeting
                {
                    Name = firstRace.Venue,
                    CountryCode = firstRace.Country,
                    RaceTypeCode = firstRace.RaceTypeCode,
                    RaceType = _codeService.GetRaceTypeFromCode(firstRace.RaceTypeCode),
                    MeetingId = firstRace.Meeting_Id
                };

                viewModel.Meetings.Add(viewMeeting);
            }

            // get the races from meetings
            foreach (var meeting in viewModel.Meetings)
            {
                foreach (var meetingEvent in events.Where(x => x.Meeting_Id == meeting.MeetingId))
                {
                    var race = Mapper.Map<ReportsPoolViewModel.Race>(meetingEvent);
                    var nswSummary = eventTrades.FirstOrDefault(
                         x => x.MeetingId == meetingEvent.Meeting_Id && x.EventNumber == meetingEvent.Event_No &&
                              x.Jurisdiction == Trading.Common.Enums.Jurisdiction.NSW);
                    var vicSummary = eventTrades.FirstOrDefault(
                             x => x.MeetingId == meetingEvent.Meeting_Id && x.EventNumber == meetingEvent.Event_No &&
                                  x.Jurisdiction == Trading.Common.Enums.Jurisdiction.VIC);
                    var qldSummary = eventTrades.FirstOrDefault(
                             x => x.MeetingId == meetingEvent.Meeting_Id && x.EventNumber == meetingEvent.Event_No &&
                                  x.Jurisdiction == Trading.Common.Enums.Jurisdiction.QLD);

                    // total up all the tote amounts
                    if (nswSummary != null)
                    {
                        race.NswTotes.Rebate = nswSummary.Rebate.GetValueOrDefault();
                        race.NswTotes.Payout = nswSummary.Return.GetValueOrDefault();
                        race.NswTotes.Trade = nswSummary.BetAmount.GetValueOrDefault();
                    }

                    if (vicSummary != null)
                    {
                        race.StabTotes.Rebate = vicSummary.Rebate.GetValueOrDefault();
                        race.StabTotes.Payout = vicSummary.Return.GetValueOrDefault();
                        race.StabTotes.Trade = vicSummary.BetAmount.GetValueOrDefault();
                    }

                    if (qldSummary != null)
                    {
                        race.QldTotes.Rebate = qldSummary.Rebate.GetValueOrDefault();
                        race.QldTotes.Payout = qldSummary.Return.GetValueOrDefault();
                        race.QldTotes.Trade = qldSummary.BetAmount.GetValueOrDefault();
                    }

                    meeting.Races.Add(race);
                }
            }

            return viewModel;
        }

        private List<SelectListItem> CreateObservations(List<SystemEnum> observations)
        {
            return observations.Select(x => new SelectListItem { Text = x.Value, Value = x.Num.ToString() }).ToList();
        }

        private List<SelectListItem> CreateTraderList(List<Trader> traders)
        {
            return traders.Where(x => x.Operator).Select(x => new SelectListItem { Text = x.Username }).ToList();
        }
    }
}