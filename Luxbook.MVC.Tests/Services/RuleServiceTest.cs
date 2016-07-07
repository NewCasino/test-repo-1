namespace Luxbook.MVC.Tests.Services
{
    using Models;
    using Moq;
    using MVC.Services;
    using NUnit.Framework;
    using Repositories;

    [TestFixture]
    internal class RuleServiceTest
    {

        private RuleService _service;
        private Mock<IRuleRepository> _repository;
        private Mock<ISecurityService> _securityService;

        [SetUp]
        public void Setup()
        {
            _securityService = new Mock<ISecurityService>();
            _repository = new Mock<IRuleRepository>();
            _service = new RuleService(_repository.Object, _securityService.Object);
        }

        [Test]
        public void UpdateRule_ShouldBlankTargetPropertyIfFixedValueComparison()
        {
            var targetValue = (decimal?)4.32;
            var rule = new Rule()
            {
                Comparison_Type = Rule.ComparisonType.FixedValue,
                Target_Value = targetValue,
                Target_Property = "foo"
            };

            _service.UpdateRule(rule);

            _repository.Verify(x => x.UpdateRule(It.Is<Rule>(r => r.Target_Property == null && r.Target_Value == targetValue)));
        }
        [Test]
        public void UpdateRule_ShouldBlankTargetValueIfCompareAgainstOtherProperty()
        {
            var targetValue = (decimal?)4.32;
            var targetProperty = "foo";
            var rule = new Rule()
            {
                Comparison_Type = Rule.ComparisonType.CompareAgainstTargetProperty,
                Target_Value = targetValue,
                Target_Property = targetProperty
            };

            _service.UpdateRule(rule);

            _repository.Verify(x => x.UpdateRule(It.Is<Rule>(r => r.Target_Property == targetProperty && !r.Target_Value.HasValue)));
        }
        [Test]
        public void AddRule_ShouldBlankTargetPropertyIfFixedValueComparison()
        {
            var targetValue = (decimal?)4.32;
            var rule = new Rule()
            {
                Comparison_Type = Rule.ComparisonType.FixedValue,
                Target_Value = targetValue,
                Target_Property = "foo"
            };

            _service.AddRule(rule);

            _repository.Verify(x => x.AddRule(It.Is<Rule>(r => r.Target_Property == null && r.Target_Value == targetValue)));
        }
        [Test]
        public void AddRule_ShouldBlankTargetValueIfCompareAgainstOtherProperty()
        {
            var targetValue = (decimal?)4.32;
            var targetProperty = "foo";
            var rule = new Rule()
            {
                Comparison_Type = Rule.ComparisonType.CompareAgainstTargetProperty,
                Target_Value = targetValue,
                Target_Property = targetProperty
            };

            _service.AddRule(rule);

            _repository.Verify(x => x.AddRule(It.Is<Rule>(r => r.Target_Property == targetProperty && !r.Target_Value.HasValue)));
        }

        [Test]
        public void AddRule_ShouldSetUsername()
        {
            var user = "foo";
            _securityService.Setup(x => x.GetCurrentUser()).Returns(user);
            var rule = new Rule()
            {

            };

            _service.AddRule(rule);

            _repository.Verify(x => x.AddRule(It.Is<Rule>(r => r.LID == user)));
        }

    }
}