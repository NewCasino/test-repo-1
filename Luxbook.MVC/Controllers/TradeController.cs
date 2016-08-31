namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Linq;
    using System.Text;
    using System.Web.Http;
    using DTO;
    using Infrastructure;
    using LuxTrader.StrategyFour;
    using NLog;
    using Services;
    using Trading.Common;
    using Trading.Library.Services;
    using IEventService = Services.IEventService;

    [RequireAuthentication]
    public class TradeController : ApiController
    {
        private readonly ITradeService _tradeService;
        private readonly IEventService _eventService;
        private readonly IConfigurationManager _configurationManager;
        private readonly Trader _strategyTrader;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public TradeController(ITradeService tradeService, IEventService eventService, IConfigurationManager configurationManager, Trader strategyTrader)
        {
            _tradeService = tradeService;
            _eventService = eventService;
            _configurationManager = configurationManager;
            _strategyTrader = strategyTrader;
        }


        [HttpGet]
        public JsonResponseBase Race(int meetingId, int eventNumber, Enums.TradeType tradeType, string trader)
        {

            // Need to set reduced staking flag before we trade
            _eventService.SetReducedStaking(meetingId, eventNumber);

            // need to actually make the live trades as TradeRace just generates them now
            var trades = _strategyTrader.TradeRace(meetingId, eventNumber, tradeType, false, trader);
            _tradeService.LiveTradeTab(trades.AllTrades, trades.SellCode, trades.RaceType, _configurationManager.GetSetting("DigitalApi.BaseUrl"));
            _tradeService.SaveTrades(trades.AllTrades);

            _logger.Warn($"Created {trades.AllTrades.Count} live trades for meeting Id {meetingId} event {eventNumber}. Trade type: {tradeType}");

            foreach (var liveTrade in trades.AllTrades)
            {
                _logger.Warn($"{string.Join("-", liveTrade.Selection)} {liveTrade.Jurisdiction} {liveTrade.Bet_Amount}");
            }

            return new JsonResponseBase() { Success = true, Message = $"Created {trades.AllTrades.Count} live trades." };

        }
    }
}