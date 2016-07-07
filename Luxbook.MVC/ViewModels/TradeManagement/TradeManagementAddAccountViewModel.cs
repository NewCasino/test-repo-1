namespace Luxbook.MVC.ViewModels.TradeManagement
{
    using System.Collections.Generic;
    using System.Web.Mvc;
    using Trading.Common;
    using Trading.Library.Models;

    public class TradeManagementAddAccountViewModel
    {
        public TradeManagementAddAccountViewModel()
        {
            Jurisdictions = new List<SelectListItem>
            {
                new SelectListItem {Text = "NSW", Value = ((int) Enums.Jurisdiction.NSW).ToString()},
                new SelectListItem {Text = "VIC", Value = ((int) Enums.Jurisdiction.VIC).ToString()}
            };
        }

        public TradingAccount Account { get; set; }
        public List<SelectListItem> Jurisdictions { get; set; }
    }
}