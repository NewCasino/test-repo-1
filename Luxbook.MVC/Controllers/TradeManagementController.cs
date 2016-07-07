namespace Luxbook.MVC.Controllers
{
    using System.Linq;
    using System.Web.Mvc;
    using DTO;
    using Extensions;
    using Trading.Library;
    using Trading.Library.Models;
    using Trading.Library.Services;
    using ViewModels.TradeManagement;

    public partial class TradeManagementController : Controller
    {
        private readonly IAccountService _accountService;
        private readonly ITradeService _tradeService;

        public TradeManagementController(IAccountService accountService, ITradeService tradeService)
        {
            _accountService = accountService;
            _tradeService = tradeService;
        }

        public virtual ActionResult Accounts()
        {
            var accounts = _accountService.GetTradingAccounts();
            var trigger = _tradeService.GetSystemTriggers().FirstOrDefault(x => x.Code.IsSameIgnoreCase("Trade"));


            var viewModel = new TradeManagementAccountsViewModel
            {
                Accounts = accounts
            };

            if (trigger != null)
            {
                viewModel.TradeEnabled = trigger.Switch;
            }

            return View(viewModel);
        }

        [HttpGet]
        public virtual JsonResult GetAllAccounts()
        {
            var accounts = _accountService.GetTradingAccounts();


            return Json(accounts, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public virtual ActionResult EditAccount(int eventTradingAccountId)
        {
            var viewModel = new TradeManagementEditAccountViewModel();

            viewModel.Account = _accountService.GetTradingAccount(eventTradingAccountId);
            return View(viewModel);
        }

        [HttpPost]
        public virtual JsonResult EditAccount(TradingAccount account)
        {
            _accountService.UpdateAccount(account);
            return Json(new JsonResponseBase { Success = true, Message = "Updated trade account" });

        }

        [HttpGet]
        public virtual ActionResult AddAccount()
        {
            var viewModel = new TradeManagementAddAccountViewModel();
            return View(viewModel);
        }

        [HttpPost]
        public virtual JsonResult AddAccount(TradingAccount viewModel)
        {
            _accountService.AddAccount(viewModel);
            return Json(new JsonResponseBase { Success = true, Message = "Added trade account" });
        }


        [HttpPost]
        public virtual JsonResult DeleteAccount(int eventTradingAccountId)
        {
            _accountService.DeleteAccount(eventTradingAccountId);
            return Json(new JsonResponseBase { Success = true, Message = "Deleted trade account" });
        }


        [HttpGet]
        public virtual JsonResult ToggleTrade(bool tradeEnabled)
        {
            _tradeService.ToggleTrade(tradeEnabled);

            return Json(new JsonResponseBase { Success = true, Message = "Updated trade setting" }, JsonRequestBehavior.AllowGet);

        }
    }
}