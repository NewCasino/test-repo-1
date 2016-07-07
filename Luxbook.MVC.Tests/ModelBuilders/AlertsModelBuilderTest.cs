namespace Luxbook.MVC.Tests.ModelBuilders
{
    using System.Collections.Generic;
    using System.Web;
    using Models;
    using Moq;
    using MVC.ModelBuilders;
    using NUnit.Framework;

    [TestFixture]
    public class AlertsModelBuilderTest
    {
        [SetUp]
        public void Setup()
        {
            _httpContextBase = new Mock<HttpContextBase>();
            _modelBuilder = new AlertsModelBuilder(_httpContextBase.Object);
        }

        private Mock<HttpContextBase> _httpContextBase;

        private AlertsModelBuilder _modelBuilder;

        [Test]
        public void CreateIndexViewModel_ShouldGroupAlerts()
        {
            var alerts = new List<Alert>
            {
                new Alert {Alert_Id = 454, Rule_Category = Rule.RuleCategory.Place},
                new Alert {Alert_Id = 86757, Rule_Category = Rule.RuleCategory.Price},
                new Alert {Alert_Id = 234, Rule_Category = Rule.RuleCategory.Place},
                new Alert {Alert_Id = 765, Rule_Category = Rule.RuleCategory.WinPercentage}
            };

            var result = _modelBuilder.CreateIndexViewModel(alerts,null);


            Assert.That(result.AlertGroups.Count, Is.EqualTo(3));

            Assert.That(result.AlertGroups[Rule.RuleCategory.Place.ToString()].Count, Is.EqualTo(2));
            Assert.That(result.AlertGroups[Rule.RuleCategory.Price.ToString()].Count, Is.EqualTo(1));
            Assert.That(result.AlertGroups[Rule.RuleCategory.WinPercentage.ToString()].Count, Is.EqualTo(1));
        }

        [Test]
        public void CreateIndexViewModel_ShouldGetUserPreferences()
        {
            var trader = new Trader()
            {
                GameTypes = "G,H"
            };
            
            var result = _modelBuilder.CreateIndexViewModel(new List<Alert>(),trader);

            Assert.That(result.MeetingTypes.Count, Is.EqualTo(2));
            Assert.That(result.MeetingTypes[0], Is.EqualTo("G"));
            Assert.That(result.MeetingTypes[1], Is.EqualTo("H"));
        }

        [Test]
        public void CreateIndexViewModel_ShouldGetUserPreferencesIfOne()
        {
            var trader = new Trader()
            {
                GameTypes = "H"
            };

            var result = _modelBuilder.CreateIndexViewModel(new List<Alert>(), trader);

            Assert.That(result.MeetingTypes.Count, Is.EqualTo(1));
            Assert.That(result.MeetingTypes[0], Is.EqualTo("H"));
        }

        [Test]
        public void CreateIndexViewModel_ShouldGetUserPreferencesEvenIfNull()
        {
            var trader = new Trader();
                

            var result = _modelBuilder.CreateIndexViewModel(new List<Alert>(),trader);

            Assert.That(result.MeetingTypes.Count, Is.EqualTo(3));
            Assert.That(result.MeetingTypes[0], Is.EqualTo("G"));
            Assert.That(result.MeetingTypes[1], Is.EqualTo("H"));
            Assert.That(result.MeetingTypes[2], Is.EqualTo("R"));
        }
    }
}