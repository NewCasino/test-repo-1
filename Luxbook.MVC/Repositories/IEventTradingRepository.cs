namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using Common;
    using Models;

    public interface IEventTradingRepository
    {
        List<EventTrading> GetTradings(DateTime startDate, DateTime endDate, Enums.RaceType raceType, bool internationalsOnly, bool paperTrades);

        List<EventTrading> GetTradings(IEnumerable<int> meetingIds);
        List<EventTradingSummary> GetTradingSummaries(IEnumerable<int> meetingIds, bool paperTrades);
        List<BetTypeSummary> GetTradingBetTypeSummaries(IEnumerable<int> meetingIds, bool paperTrades);
    }
}