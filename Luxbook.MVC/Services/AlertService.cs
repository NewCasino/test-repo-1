using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Services
{
    using Models;
    using Repositories;

    public interface IAlertService
    {
        List<Alert> GetAlerts(DateTime minimumLastTriggerTime);
        void AcknowledgeAlert(int alertId, string userId);
    }

    public class AlertService : IAlertService
    {
        private readonly IAlertRepository _alertRepository;

        public AlertService(IAlertRepository alertRepository)
        {
            _alertRepository = alertRepository;
        }

        #region Implementation of IAlertsService

        public List<Alert> GetAlerts(DateTime minimumLastTriggerTime)
        {
            var alerts = _alertRepository.GetAlerts(minimumLastTriggerTime);

            // special case where fixed odds are 9000 ignore the warning as it's a scratched race
            return alerts;
        }

        public void AcknowledgeAlert(int alertId, string userId)
        {
            _alertRepository.AcknowledgeAlert(alertId, userId);
        }

        #endregion
    }
}