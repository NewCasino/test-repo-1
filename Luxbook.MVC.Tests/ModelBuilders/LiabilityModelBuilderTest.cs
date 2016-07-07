using System.Collections.Generic;
using System.Linq;
using Luxbook.MVC.ModelBuilders;
using Luxbook.MVC.Models;
using NUnit.Framework;

namespace Luxbook.MVC.Tests.ModelBuilders
{
    [TestFixture]
    internal class LiabilityModelBuilderTest
    {
        [SetUp]
        public void Setup()
        {
            _modelBuilder = new LiabilityModelBuilder();
        }

        private LiabilityModelBuilder _modelBuilder;

        [Test]
        public void CreateLiabilityIndexViewModel_ShouldGetWinAndPlace()
        {
            var eventNo = 2;
            var meetingId = 45;
            var runnerNo = 92;
            var eventNo2 = 7;
            var meetingId2 = 245232;
            var runnerNo2 = 4;

            var winLiability = 5.432m;
            var placeLiability = -65.343m;

            var winLiability2 = 4556.3m;
            var placeLiability2 = -5323.32m;

            var liabilities = new List<RunnerLiability>
            {
                new RunnerLiability
                {
                    Bet_Type = "WIN",
                    Event_No = eventNo,
                    Meeting_Id = meetingId,
                    Runner_No = runnerNo,
                    Liability = winLiability
                },
                new RunnerLiability
                {
                    Bet_Type = "PLACE",
                    Event_No = eventNo,
                    Meeting_Id = meetingId,
                    Runner_No = runnerNo,
                    Liability = placeLiability
                },
                new RunnerLiability
                {
                    Bet_Type = "WIN",
                    Event_No = eventNo2,
                    Meeting_Id = meetingId2,
                    Runner_No = runnerNo2,
                    Liability = winLiability2
                },
                new RunnerLiability
                {
                    Bet_Type = "PLACE",
                    Event_No = eventNo2,
                    Meeting_Id = meetingId2,
                    Runner_No = runnerNo2,
                    Liability = placeLiability2
                },
                new RunnerLiability
                {
                    Bet_Type = "WIN",
                    Event_No = 8,
                    Meeting_Id = 2012791,
                    Runner_No = 6,
                    Liability = -128m
                },
                new RunnerLiability
                {
                    Bet_Type = "PLACE",
                    Event_No = 8,
                    Meeting_Id = 2012791,
                    Runner_No = 6,
                    Liability = 1232m
                }
            };

            var result = _modelBuilder.CreateLiabilityDto(liabilities);

            Assert.That(result.Count, Is.EqualTo(3));
            Assert.That(
                result.Any(
                    x =>
                        x.Meeting_Id == meetingId && x.Event_No == eventNo && x.Runner_No == runnerNo &&
                        x.Win_Liability == winLiability && x.Place_Liability == placeLiability));

            Assert.That(
                result.Any(
                    x =>
                        x.Meeting_Id == meetingId2 && x.Event_No == eventNo2 && x.Runner_No == runnerNo2 &&
                        x.Win_Liability == winLiability2 && x.Place_Liability == placeLiability2));
        }
    }
}