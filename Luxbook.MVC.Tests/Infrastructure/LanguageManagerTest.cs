using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Luxbook.MVC.Tests.Infrastructure
{
    using Models;
    using Moq;
    using MVC.Infrastructure;
    using NUnit.Framework;

    [TestFixture]
    class LanguageManagerTest
    {
        private LanguageManager _manager;
        private Mock<StringHelper> _stringHelper;


        [SetUp]
        public void Setup()
        {
            _stringHelper = new Mock<StringHelper>();
            _manager = new LanguageManager(_stringHelper.Object);
        }

        [Test]
        public void GetText_ShouldGetEnum()
        {
           var result = _manager.GetText(Rule.ComparisonType.FixedValue);

            Assert.That(result,Is.EqualTo("Fixed value"));
        }

        [Test]
        public void GetText_ShouldNormalizeNameNotInDictionary()
        {
            var splitCase = "Greater than";
            _stringHelper.Setup(x => x.SplitCamelCase("GreaterThan")).Returns(splitCase);

            var result = _manager.GetText(Rule.ComparisonOperator.GreaterThan);

            Assert.That(result,Is.EqualTo(splitCase));
        }
    }
}
