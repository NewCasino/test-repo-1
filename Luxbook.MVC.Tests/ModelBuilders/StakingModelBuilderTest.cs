using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Luxbook.MVC.Tests.ModelBuilders
{
    using Models;
    using Moq;
    using MVC.ModelBuilders;
    using NUnit.Framework;
    using Repositories;

    [TestFixture]
    public class StakingModelBuilderTest
    {

        private StakingModelBuilder _modelBuilder;

        [SetUp]
        public void Setup()
        {
            _modelBuilder = new StakingModelBuilder();
        }

        [Test]
        public void CreateStakingIndexViewModel_ShouldSplitInternationalAndAuGreys()
        {
            var stakingInt = 1;
            var stakingAus = 2;
            var stakings = new List<Staking>()
            {
                new Staking() {Staking_Id = stakingInt, Internationals = true, Market = "NSW", Pool_Id = 3 , Race_Type = "G"},
                new Staking() {Staking_Id = stakingAus, Internationals = false, Market = "NSW", Pool_Id = 3, Race_Type =  "G"},
            };

            var result = _modelBuilder.CreateStakingIndexViewModel(stakings);


            var international = result.StakingGroups.First(x => x.GroupName == "Internationals");
            var australian = result.StakingGroups.First(x => x.GroupName == "Australian");
            Assert.That(international.GreyhoundStakings.Count,Is.EqualTo(1));
            Assert.That(international.GreyhoundStakings[0].Staking_Id, Is.EqualTo(stakingInt));
            Assert.That(australian.GreyhoundStakings.Count,Is.EqualTo(1));
            Assert.That(australian.GreyhoundStakings[0].Staking_Id, Is.EqualTo(stakingAus));
        }

        [Test]
        public void CreateStakingIndexViewModel_ShouldSplitInternationalAndAuRacing()
        {
            var stakingInt = 1;
            var stakingAus = 2;
            var stakings = new List<Staking>()
            {
                new Staking() {Staking_Id = stakingInt, Internationals = true, Market = "NSW", Pool_Id = 3 , Race_Type = "R"},
                new Staking() {Staking_Id = stakingAus, Internationals = false, Market = "NSW", Pool_Id = 3, Race_Type =  "R"},
            };

            var result = _modelBuilder.CreateStakingIndexViewModel(stakings);


            var international = result.StakingGroups.First(x => x.GroupName == "Internationals");
            var australian = result.StakingGroups.First(x => x.GroupName == "Australian");
            Assert.That(international.RacingStakings.Count,Is.EqualTo(1));
            Assert.That(international.RacingStakings[0].Staking_Id, Is.EqualTo(stakingInt));
            Assert.That(australian.RacingStakings.Count,Is.EqualTo(1));
            Assert.That(australian.RacingStakings[0].Staking_Id, Is.EqualTo(stakingAus));
        }

        [Test]
        public void CreateStakingIndexViewModel_ShouldSplitInternationalAndAuHarness()
        {
            var stakingInt = 1;
            var stakingAus = 2;
            var stakings = new List<Staking>()
            {
                new Staking() {Staking_Id = stakingInt, Internationals = true, Market = "NSW", Pool_Id = 3 , Race_Type = "H"},
                new Staking() {Staking_Id = stakingAus, Internationals = false, Market = "NSW", Pool_Id = 3, Race_Type =  "H"},
            };

            var result = _modelBuilder.CreateStakingIndexViewModel(stakings);


            var international = result.StakingGroups.First(x => x.GroupName == "Internationals");
            var australian = result.StakingGroups.First(x => x.GroupName == "Australian");
            Assert.That(international.HarnessStakings.Count,Is.EqualTo(1));
            Assert.That(international.HarnessStakings[0].Staking_Id, Is.EqualTo(stakingInt));
            Assert.That(australian.HarnessStakings.Count,Is.EqualTo(1));
            Assert.That(australian.HarnessStakings[0].Staking_Id, Is.EqualTo(stakingAus));
        }
    }
}
