namespace Luxbook.MVC.Tests.Controller
{
    using Controllers;
    using LuxTrader.StrategyFour;
    using Moq;
    using MVC.Infrastructure;
    using MVC.Services;
    using NUnit.Framework;
    using Trading.Common;
    using Trading.Library.Services;

    [TestFixture]
    internal class TradeControllerTest
    {
        [SetUp]
        public void Setup()
        {
            _eventService = new Mock<MVC.Services.IEventService>();
            _configurationManager = new Mock<IConfigurationManager>();
            _tradeService = new Mock<ITradeService>();
            _trader = new Mock<Trader>();
            _controller = new TradeController(_tradeService.Object, _eventService.Object, _configurationManager.Object, _trader.Object);
        }

        private TradeController _controller;
        private Mock<ITradeService> _tradeService;
        private Mock<IConfigurationManager> _configurationManager;
        private Mock<MVC.Services.IEventService> _eventService;
        private Mock<Trader> _trader;
      
    }
}