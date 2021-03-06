﻿namespace Luxbook.MVC.ViewModels.TradeManagement
{
    using System;
    using System.Collections.Generic;
    using System.Web.Mvc;
    using Trading.Common;
    using Trading.Library.Models;

    public class TradeManagementAccountsViewModel
    {
        public TradeManagementAccountsViewModel()
        {
            Accounts = new List<TradingAccount>();
            Jurisdictions = new List<SelectListItem>()
            {
              new SelectListItem() { Text =  "NSW", Value = ((int)Enums.Jurisdiction.NSW).ToString()},
              new SelectListItem() { Text =  "VIC", Value = ((int)Enums.Jurisdiction.VIC).ToString()}
            };
        }

        public List<TradingAccount> Accounts { get; set; }

        public List<SelectListItem> Jurisdictions { get; set; }

        public bool TradeEnabled { get; set; }

    }
}