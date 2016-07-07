namespace Luxbook.MVC.Tests.ModelBuilders
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using Common;
    using Models;
    using Moq;
    using MVC.ModelBuilders;
    using MVC.Services;
    using NUnit.Framework;

    [TestFixture]
    public class ReportModelBuilderTest
    {
        private ReportModelBuilder _modelBuilder;
        private Mock<ICodeService> _codeService;

        [SetUp]
        public void Setup()
        {
            _codeService = new Mock<ICodeService>();
            _modelBuilder = new ReportModelBuilder(_codeService.Object);
        }

        [TestCase(Enums.RaceType.Greyhounds, "Greyhounds")]
        [TestCase(Enums.RaceType.Harness, "Harness")]
        [TestCase(Enums.RaceType.Races, "Races")]
        public void CreateReportsMonthlyViewModel_ShouldGetSingleRaceType(Enums.RaceType raceType, string expectedName)
        {
            var parameter = new MonthlyReportParameter
            {
                RaceType = raceType,
                StartDate = DateTime.Today,
                EndDate = DateTime.Today.AddMonths(1)
            };

            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, new List<EventTrading>());

            Assert.That(result.RaceTypes, Is.EqualTo(expectedName));
        }

        [Test]
        public void CreateReportsMonthlyViewModel_ShouldSplitIntoMonthlyTrades()
        {
            var parameter = new MonthlyReportParameter
            {
                StartDate = DateTime.Today.AddMonths(-2),
                EndDate = DateTime.Today
            };

            var eventTradings = new List<EventTrading>
            {
                new EventTrading {DateCreated = DateTime.Today.AddMonths(-2)},
                new EventTrading {DateCreated = DateTime.Today.AddMonths(-2)},
                new EventTrading {DateCreated = DateTime.Today.AddMonths(-1)},
                new EventTrading {DateCreated = DateTime.Today.AddMonths(-1)},
                new EventTrading {DateCreated = DateTime.Today},
                new EventTrading {DateCreated = DateTime.Today}
            };
            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);


            Assert.That(result.ReportsMonthly.Count, Is.EqualTo(3));
        }

        /// <summary>
        ///     Makes sure that for dates we don't have data we still have an entry
        /// </summary>
        [Test]
        public void CreateReportsMonthlyViewModel_ShouldInsertGapsInTrades()
        {
            var parameter = new MonthlyReportParameter
            {
                StartDate = new DateTime(2015, 2, 1),
                EndDate = new DateTime(2015, 4, 1)
            };

            var eventTradings = new List<EventTrading>
            {
                new EventTrading {DateCreated = new DateTime(2015, 2, 1)},
                new EventTrading {DateCreated = new DateTime(2015, 3, 1)},
                new EventTrading {DateCreated = new DateTime(2015, 4, 1)}
            };
            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);

            Assert.That(result.ReportsMonthly[0].Reports.Count, Is.EqualTo(28)); // feb has 28 days
            Assert.That(result.ReportsMonthly[1].Reports.Count, Is.EqualTo(31)); // march has 31 days etc.
            Assert.That(result.ReportsMonthly[2].Reports.Count, Is.EqualTo(30));
        }

        /// <summary>
        ///     Makes sure that for dates we don't have data we still have an entry
        /// </summary>
        [Test]
        public void CreateReportsMonthlyViewModel_ShouldInsertTradesIntoCorrectGroups()
        {
            var parameter = new MonthlyReportParameter
            {
                StartDate = new DateTime(2015, 2, 1),
                EndDate = new DateTime(2015, 4, 1)
            };

            var betAmount = 404m;
            var eventTradings = new List<EventTrading>
            {
                new EventTrading {DateCreated = new DateTime(2015, 2, 3), BetAmount = betAmount},
                new EventTrading {DateCreated = new DateTime(2015, 3, 1)},
                new EventTrading {DateCreated = new DateTime(2015, 4, 1)}
            };
            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);

            Assert.That(result.ReportsMonthly[0].Reports.Any(x => x.Trade == betAmount)); // feb has 28 days
        }

        /// <summary>
        ///     Makes sure that for days with multiple trades we are totalling them up
        /// </summary>
        [Test]
        public void CreateReportsMonthlyViewModel_ShouldTotalUpTradesForTheDay()
        {
            var parameter = new MonthlyReportParameter
            {
                StartDate = new DateTime(2015, 2, 1),
                EndDate = new DateTime(2015, 4, 1)
            };

            var betAmount = 404m;
            var betAmount2 = 100m;
            var yield = 10m;
            var yield2 = 3044m;

            var eventTradings = new List<EventTrading>
            {
                new EventTrading {DateCreated = new DateTime(2015, 2, 3), BetAmount = betAmount},
                new EventTrading {DateCreated = new DateTime(2015, 2, 3), BetAmount = betAmount2},
                new EventTrading {DateCreated = new DateTime(2015, 2, 4), BetAmount = betAmount2},
                new EventTrading {DateCreated = new DateTime(2015, 2, 4), BetAmount = betAmount2},
                new EventTrading {DateCreated = new DateTime(2015, 3, 1), Return = yield},
                new EventTrading {DateCreated = new DateTime(2015, 3, 1), Return = yield2},
                new EventTrading {DateCreated = new DateTime(2015, 4, 1)}
            };
            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);

            Assert.That(result.ReportsMonthly[0].Reports.Count, Is.EqualTo(28)); // feb has 28 days
            Assert.That(result.ReportsMonthly[0].Reports.Any(x => x.Trade == betAmount + betAmount2));
            Assert.That(result.ReportsMonthly[0].Reports.Any(x => x.Trade == betAmount2 + betAmount2));
            Assert.That(result.ReportsMonthly[1].Reports.Any(x => x.Return.Value == yield + yield2));
        }

        /// <summary>
        ///     Makes sure that the days are ordered properly!
        /// </summary>
        [Test]
        public void CreateReportsMonthlyViewModel_ShouldOrderDaysInMonth()
        {
            var parameter = new MonthlyReportParameter
            {
                StartDate = new DateTime(2015, 2, 1),
                EndDate = new DateTime(2015, 4, 1)
            };

            var betAmount = 404m;
            var betAmount2 = 100m;
            var yield = 10m;
            var yield2 = 3044m;

            var eventTradings = new List<EventTrading>
            {
                new EventTrading {DateCreated = new DateTime(2015, 2, 3), BetAmount = betAmount},
                new EventTrading {DateCreated = new DateTime(2015, 2, 3), BetAmount = betAmount2}
            };
            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);

            Assert.That(result.ReportsMonthly[0].Reports.Count, Is.EqualTo(28)); // feb has 28 days
            for (int i = 1; i <= 28; i++)
            {
                Assert.That(result.ReportsMonthly[0].Reports[i - 1].ReportDate.Day, Is.EqualTo(i));
            }
        }

        /// <summary>
        ///     Makes sure that even if we have no trades we are still generating gaps based on today's date
        /// </summary>
        [Test]
        public void CreateReportsMonthlyViewModel_ShouldInsertGapsInTradesForMonthsWithNoTrade()
        {
            var today = DateTime.Today;
            var todayLastMonth = DateTime.Today.AddMonths(-1);
            var today2MonthsAgo = DateTime.Today.AddMonths(-2);

            var parameter = new MonthlyReportParameter { StartDate = today2MonthsAgo, EndDate = today };

            var eventTradings = new List<EventTrading>();

            var result = _modelBuilder.CreateReportsMonthlyViewModel(parameter, eventTradings);

            var currentMonth = DateTime.DaysInMonth(today.Year, today.Month);
            var lastMonth = DateTime.DaysInMonth(todayLastMonth.Year, todayLastMonth.Month);
            var twoMonthsAgo = DateTime.DaysInMonth(today2MonthsAgo.Year, today2MonthsAgo.Month);

            Assert.That(result.ReportsMonthly.Count, Is.EqualTo(3));
            Assert.That(result.ReportsMonthly[0].Reports.Count, Is.EqualTo(twoMonthsAgo)); // feb has 28 days
            Assert.That(result.ReportsMonthly[1].Reports.Count, Is.EqualTo(lastMonth)); // march has 31 days etc.
            Assert.That(result.ReportsMonthly[2].Reports.Count, Is.EqualTo(currentMonth));
        }

        [Test]
        public void CreateReportsPool_ShouldProcessMeetings()
        {
            var parameters = new PoolReportParameters();
            var meetingId = 1;
            var eventNumber = 2;
            var type1 = "G";
            var type2 = "R";
            var events = new List<Event>
            {
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber + 1,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId + 2,
                    Event_No = eventNumber,
                    Venue = "ASCOT",
                    RaceTypeCode = type2,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId + 2,
                    Event_No = eventNumber + 1,
                    Venue = "ASCOT",
                    RaceTypeCode = type2,
                    Country = "NZ",
                    Status = "DONE"
                }
            };
            _codeService.Setup(x => x.GetRaceTypeFromCode(type1)).Returns(Enums.RaceType.Greyhounds);
            _codeService.Setup(x => x.GetRaceTypeFromCode(type2)).Returns(Enums.RaceType.Races);

            var result = _modelBuilder.CreateReportsPoolViewModel(parameters, new List<EventTradingSummary>(), new List<Trader>(),
                new List<SystemEnum>(), events);

            Assert.That(result.Meetings.Count, Is.EqualTo(2));
            Assert.That(result.Meetings.Any(x => x.Name == "PAKENHAM" && x.RaceType == Enums.RaceType.Greyhounds));
            Assert.That(result.Meetings.Any(x => x.Name == "ASCOT" && x.RaceType == Enums.RaceType.Races));
        }

        [Test]
        public void CreateReportsPool_ShouldProcessRaces()
        {
            var parameters = new PoolReportParameters();
            var meetingId = 1;
            var eventNumber = 2;
          
            var type1 = "G";
            var type2 = "R";
            var events = new List<Event>
            {
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber + 1,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId + 2,
                    Event_No = eventNumber,
                    Venue = "ASCOT",
                    RaceTypeCode = type2,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId + 2,
                    Event_No = eventNumber + 1,
                    Venue = "ASCOT",
                    RaceTypeCode = type2,
                    Country = "NZ",
                    Status = "DONE"
                }
            };
            _codeService.Setup(x => x.GetRaceTypeFromCode(type1)).Returns(Enums.RaceType.Greyhounds);
            _codeService.Setup(x => x.GetRaceTypeFromCode(type2)).Returns(Enums.RaceType.Races);

            var result = _modelBuilder.CreateReportsPoolViewModel(parameters, new List<EventTradingSummary>(), new List<Trader>(),
                new List<SystemEnum>(), events);

            Assert.That(result.Meetings.Count, Is.EqualTo(2));
            Assert.That(result.Meetings.Any(x => x.Name == "PAKENHAM" && x.Races.Count == 2));
            Assert.That(result.Meetings.Any(x => x.Name == "ASCOT" && x.Races.Count == 2));

            var pakenham = result.Meetings.First(x => x.Name == "PAKENHAM");

            Assert.That(pakenham.Races[0].Number == eventNumber);
            Assert.That(pakenham.Races[1].Number == eventNumber + 1);
        }

        [Test]
        public void CreateReportsPool_ShouldProcessTotes()
        {
            var parameters = new PoolReportParameters();
            var meetingId = 1;
            var eventNumber = 2;
            var singleBet = 56.78m;
            var singleReturn = 3.45m;
            var singleRebate = 0.54m;
            var trades = new List<EventTradingSummary>
            {
                new EventTradingSummary
                {
                    MeetingId = meetingId,
                    EventNumber = eventNumber,
                    BetAmount = singleBet * 3,
                    Return = singleReturn* 3,
                    Jurisdiction = Trading.Common.Enums.Jurisdiction.NSW,
                    Rebate = singleRebate* 3
                },
                new EventTradingSummary
                {
                    MeetingId = meetingId,
                    EventNumber = eventNumber,
                    BetAmount = singleBet,
                    Jurisdiction = Trading.Common.Enums.Jurisdiction.VIC,
                    Rebate = singleRebate,
                    Return = singleReturn
                },
                new EventTradingSummary
                {
                    MeetingId = meetingId,
                    EventNumber = eventNumber,
                    BetAmount = singleBet * 2,
                    Jurisdiction = Trading.Common.Enums.Jurisdiction.QLD,
                    Rebate = singleRebate* 2,
                    Return = singleReturn* 2
                }
            };
            var type1 = "G";
            var type2 = "R";
            var events = new List<Event>
            {
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                },
                new Event
                {
                    Meeting_Id = meetingId,
                    Event_No = eventNumber + 1,
                    Venue = "PAKENHAM",
                    RaceTypeCode = type1,
                    Country = "NZ",
                    Status = "DONE"
                }
            };
            _codeService.Setup(x => x.GetRaceTypeFromCode(type1)).Returns(Enums.RaceType.Greyhounds);
            _codeService.Setup(x => x.GetRaceTypeFromCode(type2)).Returns(Enums.RaceType.Races);

            var result = _modelBuilder.CreateReportsPoolViewModel(parameters, trades, new List<Trader>(),
                new List<SystemEnum>(), events);

            var pakenham = result.Meetings.First(x => x.Name == "PAKENHAM");
            var raceOne = pakenham.Races.First(x => x.Number == eventNumber);

            Assert.That(raceOne.NswTotes.Trade, Is.EqualTo(singleBet * 3));
            Assert.That(raceOne.StabTotes.Trade, Is.EqualTo(singleBet));
            Assert.That(raceOne.QldTotes.Trade, Is.EqualTo(singleBet * 2));
            Assert.That(raceOne.NswTotes.Rebate, Is.EqualTo(singleRebate * 3));
            Assert.That(raceOne.StabTotes.Rebate, Is.EqualTo(singleRebate));
            Assert.That(raceOne.QldTotes.Rebate, Is.EqualTo(singleRebate * 2));
            Assert.That(raceOne.NswTotes.Payout, Is.EqualTo(singleReturn * 3));
            Assert.That(raceOne.StabTotes.Payout, Is.EqualTo(singleReturn));
            Assert.That(raceOne.QldTotes.Payout, Is.EqualTo(singleReturn * 2));


        }
    }
}