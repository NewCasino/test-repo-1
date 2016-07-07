namespace Luxbook.MVC.Tests.ModelBuilders
{
    using System.Collections.Generic;
    using Models;
    using Moq;
    using MVC.Infrastructure;
    using MVC.ModelBuilders;
    using NUnit.Framework;

    [TestFixture]
    public class RulesModelBuilderTest
    {
        private Mock<ILanguageManager> _languageManager;

        [SetUp]
        public void Setup()
        {
            _languageManager = new Mock<ILanguageManager>();
            _modelBuilder = new RulesModelBuilder(_languageManager.Object);
        }

        private RulesModelBuilder _modelBuilder;

        [Test]
        public void CreateManageViewModel_ShouldMapRules()
        {
            var rule = new Rule { Rule_Id = 434, Name = "Elvis" };
            var rules = new List<Rule>
            {
                rule
            };

            var result = _modelBuilder.CreateManageViewModel(rules);

            Assert.That(result.Rules.Count, Is.EqualTo(1));

            Assert.That(result.Rules[0].RuleId, Is.EqualTo(rule.Rule_Id));
            Assert.That(result.Rules[0].Name, Is.EqualTo(rule.Name));
        }
    }
}