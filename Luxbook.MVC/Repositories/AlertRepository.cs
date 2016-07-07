namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface IAlertRepository
    {
        List<Alert> GetAlerts(DateTime minimumLastTriggerTime);
        void AcknowledgeAlert(int alertId, string userId);
    }

    public class AlertRepository : IAlertRepository
    {
        private readonly IDatabase _database;

        public AlertRepository(IDatabase database)
        {
            _database = database;
        }

        public List<Alert> GetAlerts(DateTime minimumLastTriggerTime)
        {
            // we aren't really doing async at the moment
            return _database.Query<Alert>("sp_Alerts_Get", new
            {
                MINIMUM_TRIGGER_TIME = minimumLastTriggerTime
            }).ToList();
        }

        public void AcknowledgeAlert(int alertId, string userId)
        {
            _database.Execute("sp_alert_acknowledge", new
            {
                ALERT_ID = alertId,
                LID = userId
            });
        }
    }
}