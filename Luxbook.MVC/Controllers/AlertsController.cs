using Newtonsoft.Json;

namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.Web.Mvc;
    using Infrastructure;
    using ModelBuilders;
    using Models;
    using NLog;
    using Services;

    [RequireAuthentication]
    public partial class AlertsController : Controller
    {
        private readonly IAlertService _alertService;
        private readonly IAlertsModelBuilder _alertsModelBuilder;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();
        private readonly ISecurityService _securityService;
        private readonly ITraderService _traderService;

        public AlertsController(IAlertService alertService, IAlertsModelBuilder alertsModelBuilder,
            ISecurityService securityService, ITraderService traderService)
        {
            _alertService = alertService;
            _alertsModelBuilder = alertsModelBuilder;
            _securityService = securityService;
            _traderService = traderService;
        }

        // GET: Alerts
        public virtual ActionResult Index()
        {

            var viewModel = _alertsModelBuilder.CreateIndexViewModel(new List<Alert>(), _traderService.GetCurrentTrader());

            return View(viewModel);
        }

        [HttpGet]
        public virtual ActionResult GetAll()
        {
            var alerts = _alertService.GetAlerts(DateTime.Now.AddMinutes(-5));
            var viewModel = _alertsModelBuilder.CreateIndexViewModel(alerts, null);
            var json = JsonConvert.SerializeObject(viewModel);
            var result = new ContentResult
            {
                Content = json,
                ContentType = "application/json"
            };
            // Explicitly allow get as the vulnerability only exists if we send a JSON array. We're sending a JSON object
            // See http://haacked.com/archive/2009/06/25/json-hijacking.aspx/
            return result;
        }

        [HttpPost]
        public virtual JsonResult UpdatePreferences(Trader trader)
        {

            _traderService.UpdateTrader(trader);
            var jsonResult = new JsonResult
            {
                Data = true
            };
            return jsonResult;
        }

        [HttpPost]
        public virtual ActionResult Acknowledge(int alertId)
        {
            try
            {
                _alertService.AcknowledgeAlert(alertId, _securityService.GetCurrentUser());
            }
            catch (Exception ex)
            {
                _logger.Error("Error acknowledging alert: {0}", ex.Message);
                throw;
            }

            var jsonResult = new JsonResult
            {
                Data = true
            };
            return jsonResult;
        }
    }
}