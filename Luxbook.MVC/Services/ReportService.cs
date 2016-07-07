namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Common;
    using Models;
    using Repositories;

    public interface IReportService
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <param name="raceType"></param>
        /// <param name="internationalsOnly"></param>
        /// <param name="paperTrades">Determines if we are looking for paper trades or live trades</param>
        /// <returns></returns>
        List<EventTrading> GetTradings(DateTime startDate, DateTime endDate, Enums.RaceType raceType, bool internationalsOnly, bool paperTrades);

        /// <summary>
        ///     Returns trades for all the specified meetings
        /// </summary>
        /// <param name="meetingIds"></param>
        /// <param name="paperTrades">Determines if we are getting live or paper trades</param>
        /// <returns></returns>
        List<EventTradingSummary> GetTradingSummaries(IEnumerable<int> meetingIds, bool paperTrades);

        /// <summary>
        /// 
        /// </summary>
        /// <param name="meetingIds"></param>
        /// <param name="paperTrades">Determines if we are getting live or paper trades</param>
        /// <returns></returns>
        List<BetTypeSummary> GetTradingBetTypeSummaries(IEnumerable<int> meetingIds, bool paperTrades);
    }

    public class ReportService : IReportService
    {
        private readonly IEventTradingRepository _repository;

        public List<BetTypeSummary> GetTradingBetTypeSummaries(IEnumerable<int> meetingIds, bool paperTrades)
        {
            return _repository.GetTradingBetTypeSummaries(meetingIds, paperTrades);
        }


        public ReportService(IEventTradingRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        ///     Returns trades for the given time, race type filter. Can also only show internationals.
        /// </summary>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <param name="raceType"></param>
        /// <param name="internationalsOnly"></param>
        /// <param name="paperTrades"></param>
        /// <returns></returns>
        public List<EventTrading> GetTradings(DateTime startDate, DateTime endDate, Enums.RaceType raceType, bool internationalsOnly, bool paperTrades)
        {
            return _repository.GetTradings(startDate, endDate, raceType, internationalsOnly, paperTrades);
        }

        /// <summary>
        ///     Returns trades for all the specified meetings
        /// </summary>
        /// <param name="meetingIds"></param>
        /// <param name="paperTrades"></param>
        /// <returns></returns>
        public List<EventTradingSummary> GetTradingSummaries(IEnumerable<int> meetingIds, bool paperTrades)
        {
            return _repository.GetTradingSummaries(meetingIds, paperTrades);
        }
    }
}