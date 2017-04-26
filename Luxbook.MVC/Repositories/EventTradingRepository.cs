namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Common;
    using Infrastructure;
    using Models;

    public class EventTradingRepository : IEventTradingRepository
    {
        private readonly IDatabase _database;

        public EventTradingRepository(IDatabase database)
        {
            _database = database;
        }

        public List<EventTrading> GetTradings(DateTime startDate, DateTime endDate, Enums.RaceType raceType, bool internationalsOnly, bool paperTrades)
        {

            // Can be summarized in the db

            //select cast(floor(cast(date_created as float)) as datetime), sum([return]) as [return], sum(BET_AMOUNT) as expenditure, sum([return]) -sum(bet_amount) as profit from event_Trading
            //      where meeting_id in (
            //      select meeting_id from meeting_tab where country not in ('au')) and success = 1
            //group by cast(floor(cast(date_created as float)) as datetime)

            var sql = @"SELECT [RETURN], BET_AMOUNT AS BetAmount, REBATE, ET.DATE_CREATED as DateCreated, BET_TYPE as BetType, [TYPE] as RaceType, ET.MEETING_ID as MeetingId, EVENT_NO as EventNumber FROM 
                EVENT_TRADING ET 
                INNER JOIN MEETING_TAB M ON M.MEETING_ID = ET.MEETING_ID AND TYPE IN @raceTypes
                WHERE ET.DATE_CREATED BETWEEN @startDate AND @endDate";

            if (internationalsOnly)
            {
                sql += " AND M.COUNTRY != 'AU'";
            }
           
            sql += $" AND PAPER_TRADE = {(paperTrades ? 1 : 0)}  and [RETURN] is not null" ;

            return _database.Query<EventTrading>(sql, new
            {
                startDate,
                endDate,
                raceTypes = GetRaceTypeCodes(raceType)
            } , commandType: CommandType.Text).ToList();
        }

        public List<EventTrading> GetTradings(IEnumerable<int> meetingIds)
        {
            var sql = @"SELECT [RETURN], BET_AMOUNT AS BetAmount, ET.DATE_CREATED as DateCreated, BET_TYPE as BetType, [TYPE] as RaceType, ET.MEETING_ID as MeetingId, EVENT_NO as EventNumber, ET.Jurisdiction FROM 
                EVENT_TRADING ET 
                INNER JOIN MEETING_TAB M ON M.MEETING_ID = ET.MEETING_ID AND M.MEETING_ID in @meetingIds
                WHERE SUCCESS = 1";

            return _database.Query<EventTrading>(sql, new
            {
              meetingIds
            } , commandType: CommandType.Text).ToList();
        }

        public List<EventTradingSummary> GetTradingSummaries(IEnumerable<int> meetingIds, bool paperTrades)
        {
            var sql =$@"
				SELECT sum([return]) as [return], sum(bet_amount) as BetAmount, sum(REBATE)/100 as Rebate, jurisdiction, et.meeting_id as MeetingId, event_no as EventNumber
				FROM Event_Trading et
				WHERE MEETING_ID in @meetingIds AND PAPER_TRADE = {(paperTrades ? 1 : 0)} and [RETURN] is not null
				GROUP BY jurisdiction, et.meeting_id, event_no
				ORDER BY meetingid, event_no";

            return _database.Query<EventTradingSummary>(sql, new
            {
                meetingIds
            }, commandType: CommandType.Text).ToList();
        } 

        public List<BetTypeSummary> GetTradingBetTypeSummaries(IEnumerable<int> meetingIds, bool paperTrades)
        {
            var sql = $@"
				SELECT sum([return]) as [return], sum(bet_amount) as BetAmount, sum(REBATE)/100 as Rebate, bet_type as BetType, et.meeting_id as MeetingId, event_no as EventNumber
				FROM Event_Trading et
				WHERE MEETING_ID in @meetingIds  and (PAPER_TRADE = {(paperTrades ? 1 : 0)})  and [RETURN] is not null
				GROUP BY bet_type, et.meeting_id, event_no
				ORDER BY meeting_id, event_no";

            return _database.Query<BetTypeSummary>(sql, new
            {
                meetingIds
            }, commandType: CommandType.Text).ToList();
        } 

        /// <summary>
        ///     Gets a list of race type codes from the race type enum flag
        /// </summary>
        /// <param name="raceType"></param>
        /// <returns></returns>
        private List<string> GetRaceTypeCodes(Enums.RaceType raceType)
        {
            List<string> result = new List<string>();
            foreach (Enums.RaceType r in Enum.GetValues(typeof (Enums.RaceType)))
            {
                if ((raceType & r) != 0) result.Add(TranslateRaceTypeCode(r));
            }

            return result;
        }

        private string TranslateRaceTypeCode(Enums.RaceType raceType)
        {
            switch (raceType)
            {
                case Enums.RaceType.Greyhounds:
                    return "G";
                case Enums.RaceType.Harness:
                    return "H";
                case Enums.RaceType.Races:
                    return "R";
            }

            throw new ArgumentException("Unknown race type " + raceType);
        }
    }
}