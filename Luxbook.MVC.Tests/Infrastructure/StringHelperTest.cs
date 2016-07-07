namespace Luxbook.MVC.Tests.Infrastructure
{
    using MVC.Infrastructure;
    using NUnit.Framework;

    [TestFixture]
    internal class StringHelperTest
    {
        private StringHelper _helper;

        [SetUp]
        public void Setup()
        {
            _helper = new StringHelper();
        }

        [TestCase("CamelCase", "Camel Case")]
        [TestCase("ElvisPresley", "Elvis Presley")]
        [TestCase("StevieWonder", "Stevie Wonder")]
        public void SplitCamelCase_ShouldSplitTwoWords(string input, string expected)
        {
            var result = _helper.SplitCamelCase(input);

            Assert.That(result, Is.EqualTo(expected));
        }

        [TestCase("CamelCamelCase", "Camel Camel Case")]
        [TestCase("KingElvisPresley", "King Elvis Presley")]
        [TestCase("SuperManStevieWonder", "Super Man Stevie Wonder")]
        public void SplitCamelCase_ShouldSplitThreeOrMoreWords(string input, string expected)
        {
            var result = _helper.SplitCamelCase(input);

            Assert.That(result, Is.EqualTo(expected));
        }

        [TestCase("CamelID", "Camel ID")]
        public void SplitCamelCase_ShouldSplitTwoWordsWithConsecutiveUppercase(string input, string expected)
        {
            var result = _helper.SplitCamelCase(input);

            Assert.That(result, Is.EqualTo(expected));
        }

        [TestCase("pascalCase", "pascal Case")]
        public void SplitCamelCase_ShouldSplitPascalCase(string input, string expected)
        {
            var result = _helper.SplitCamelCase(input);

            Assert.That(result, Is.EqualTo(expected));
        }
    }
}