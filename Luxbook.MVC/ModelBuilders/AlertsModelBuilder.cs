namespace Luxbook.MVC.ModelBuilders
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using AutoMapper;
    using Models;
    using ViewModels.Alerts;

    public interface IAlertsModelBuilder
    {
        IndexViewModel CreateIndexViewModel(IEnumerable<Alert> alerts, Trader getTrader);
    }

    public class AlertsModelBuilder : IAlertsModelBuilder
    {
        private readonly HttpContextBase _httpContextBase;

        public AlertsModelBuilder(HttpContextBase httpContextBase)
        {
            _httpContextBase = httpContextBase;
            Mapper.CreateMap<Alert, IndexViewModel.Alert>();
        }

        #region Implementation of IAlertsModelBuilder

        public IndexViewModel CreateIndexViewModel(IEnumerable<Alert> alerts, Trader trader)
        {
            var viewModel = new IndexViewModel();

            // basically create a dictionary of alerts, with the rule category as the key
            // if it's too complicated just do a foreach loop on alerts
            // and generate the dictionary
            viewModel.AlertGroups = alerts
                .GroupBy(x => x.Rule_Category)
                .Select(group => Mapper.Map<List<IndexViewModel.Alert>>(group)) // create multiple lists of alerts, grouped by rule category
                .ToDictionary(keySelect => keySelect.First().Rule_Category.ToString());
            // choose the rule_category from every list as the key

            // Choose the default meeting types if none specified
            if (trader == null || trader.GameTypes == null)
            {
                viewModel.MeetingTypes.AddRange(new[] { "G", "H", "R" });
            }
            else
            {
                viewModel.MeetingTypes.AddRange(trader.GameTypes.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries));
            }

            // Choose the default percentage filter if none specified
            if (trader == null || !trader.MinimumPercentage.HasValue)
            {
                viewModel.PercentageFilter = 2;
            }
            else
            {
                viewModel.PercentageFilter = trader.MinimumPercentage.Value;
            }

            if (trader != null)
            {
                viewModel.RaceEndStartTimeFilter = trader.RaceEndStartTimeFilter;
                viewModel.RaceStartTimeFilter = trader.RaceStartTimeFilter;
            }
            

            return viewModel;
        }

        #endregion
    }
}