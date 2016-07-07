namespace Luxbook.MVC.Tests.Services
{
    using System.Web;
    using Models;
    using Moq;
    using MVC.Services;
    using NUnit.Framework;
    using Repositories;

    [TestFixture]
    internal class TraderServiceTest
    {
        [SetUp]
        public void Setup()
        {
            _httpContextBase = new Mock<HttpContextBase>();
            _repository = new Mock<ITraderRepository>();
            _service = new TraderService(_httpContextBase.Object, _repository.Object);
        }


        private TraderService _service;
        private Mock<ITraderRepository> _repository;
        private Mock<HttpContextBase> _httpContextBase;

        [Test]
        public void UpdateTrader_ShouldGetTraderUsernameFromSession()
        {
            var trader = new Trader()
            {
                Username = "bad"
            };
            var session = new Mock<HttpSessionStateBase>();
            _httpContextBase.Setup(x => x.Session).Returns(session.Object);
            var actualUsername = "good";
            session.Setup(x => x["LID"]).Returns(actualUsername);

            _service.UpdateTrader(trader);

            _repository.Verify(x=>x.UpdatePreferences(It.Is<Trader>(t=> t.Username == actualUsername)));
        }
    }
}