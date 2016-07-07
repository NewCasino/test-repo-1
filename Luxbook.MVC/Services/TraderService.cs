namespace Luxbook.MVC.Services
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using Models;
    using Repositories;

    /// <summary>
    /// Deals with traders (e.g. users)
    /// </summary>
    public interface ITraderService
    {
        void UpdateTrader(Trader trader);
        Trader GetCurrentTrader();
        List<Trader> GetTraders();
    }

    public class TraderService : ITraderService
    {
        private readonly HttpContextBase _httpContextBase;
        private readonly ITraderRepository _traderRepository;

        public TraderService(HttpContextBase httpContextBase, ITraderRepository traderRepository)
        {
            _httpContextBase = httpContextBase;
            _traderRepository = traderRepository;
        }

        public void UpdateTrader(Trader trader)
        {
            var actualSession = _httpContextBase.Session["LID"] as string;

            trader.Username = actualSession;

            _traderRepository.UpdatePreferences(trader);
        }

        public Trader GetCurrentTrader()
        {
            var trader = _traderRepository.GetTrader(_httpContextBase.Session["LID"] as string);
           
            return trader;
        }

        public List<Trader> GetTraders()
        {
            var traders = _traderRepository.GetAllTraders();

            return traders;
        } 
    }
}