namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;
    using DTO;

    public interface ITraderAssignRepository
    {
        TraderAssignMetaResponse GetAssignments(string meetingDate);
        List<TraderAssignWithMeta> GetAssignmentsByDate(string mode, string date);
        void SaveAssignments(List<TraderAssign> assignments);
        void DeleteAssignments(int traderAssignId);
    }

    public class TraderAssignRepository : ITraderAssignRepository
    {
        private readonly IDatabase _database;

        public TraderAssignRepository(IDatabase database)
        {
            _database = database;
        }

        public TraderAssignMetaResponse GetAssignments(string meetingDate)
        {

            var meetings =
                _database.Query<MeetingTags>(@"SELECT m.Meeting_Id, m.Meeting_Date,
                                                m.Country, m.Type, m.Venue, m.Btk_Id, m.Events as Event_Cnt, m.Wift_Mtg_Id, sb.Region
                                            FROM dbo.MEETING_TAB as m
                                            LEFT JOIN SYS_BETTEKK sb ON sb.CODE = m.BTK_ID
                                            WHERE m.MEETING_Date = @meetingDate
                                            ORDER BY m.Venue",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var events =
                _database.Query<EventTags>(@"SELECT e.Meeting_id, e.Event_No, e.Start_Time, e.Name, e.Region
                                            FROM dbo.EVENT_TAB as e
                                            INNER JOIN dbo.MEETING_TAB as m ON (e.meeting_id=m.meeting_id)                                            
                                            WHERE m.MEETING_Date = @meetingDate",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            // populate each meeting with an events list
            foreach (var m in meetings)
            {
                m.Events = events.Where(e => e.Meeting_Id == m.Meeting_Id).ToList();
            }

            var traders =
                _database.Query<TraderTags>(@"SELECT t.Lid, t.Name, t.Lvl, t.Lux, t.Tab, t.Sun
                                            FROM dbo.TRADER as t
                                            WHERE LVL < 10;", // ignore media users
                    new
                    {
                    }, commandType: CommandType.Text);

            var assignments =
                _database.Query<TraderAssign>(@"SELECT ta.*
                                            FROM dbo.TRADER_ASSIGN as ta
                                            INNER JOIN MEETING_TAB M ON M.MEETING_ID = ta.MEETING_ID
                                            WHERE m.Meeting_Date = @meetingDate
                                            ORDER BY MEETING_ID, EVENT_NO;",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var assignResponse = new TraderAssignMetaResponse
            {
                Meetings = meetings.ToList(),
                Traders = traders.ToList(),
                Assignments = assignments.ToList(),
            };

            return assignResponse;

        }

        public void RemoveAssignment(int traderAssignmentId)
        {

        }

        public List<TraderAssignWithMeta> GetAssignmentsByDate(string mode, string date)
        {
            // note:- this may change in future
            var sql = (mode == "meeting" ?
                            @"SELECT m.Meeting_Date, 
                                    e.Meeting_id, e.Event_No, ta.ASSIGNMENT_DATE, e.Start_Time, m.Country, m.Type, e.Name, sb.Region, m.Venue,
                                    ta.Lux_Trader, ta.Tab_Trader, ta.Sun_Trader, ta.Lux_Ma, ta.Tab_Ma, ta.Sun_Ma, m.events as EventsInMeeting, ta.LID, ta.TRADER_ASSIGN_ID, t.NAME as TraderName    
                                    FROM dbo.TRADER_ASSIGN as ta
                                    INNER JOIN EVENT_TAB e ON (ta.MEETING_ID=e.MEETING_ID and ta.EVENT_NO=e.EVENT_NO)
                                    INNER JOIN MEETING_TAB m ON (ta.MEETING_ID=m.MEETING_ID)
                                    INNER JOIN SYS_BETTEKK sb ON m.BTK_ID = sb.CODE
                                    INNER JOIN TRADER t ON t.LID  = ta.LID
                                    WHERE m.Meeting_Date = @Date
                                    ORDER BY 2, 3, 4;"
                        :
                            @"SELECT m.Meeting_Date, 
                                    e.Meeting_id, e.Event_No, ta.ASSIGNMENT_DATE, e.Start_Time, m.Country, m.Type, e.Name, sb.Region, m.Venue,
                                    ta.Lux_Trader, ta.Tab_Trader, ta.Sun_Trader, ta.Lux_Ma, ta.Tab_Ma, ta.Sun_Ma
                                    FROM dbo.TRADER_ASSIGN as ta
                                    INNER JOIN EVENT_TAB e ON (ta.MEETING_ID=e.MEETING_ID and ta.EVENT_NO=e.EVENT_NO)
                                    INNER JOIN MEETING_TAB m ON (ta.MEETING_ID=m.MEETING_ID)
                                    INNER JOIN SYS_BETTEKK sb ON m.BTK_ID = sb.CODE
                                    WHERE ta.ASSIGNMENT_DATE = @Date
                                    ORDER BY 2, 3, 4;"
                );
            var assignments =
                _database.Query<TraderAssignWithMeta>(sql,
                    new
                    {
                        Date = date
                    }, commandType: CommandType.Text);

            return assignments.ToList();

        }

        public void SaveAssignments(List<TraderAssign> assignments)
        {
            // insert new assignments for meeting_id
            var sql = @"INSERT INTO TRADER_ASSIGN 
                        (ASSIGNMENT_DATE, MEETING_ID,LID, EVENT_NO, LUX_TRADER, LUX_MA, TAB_TRADER, TAB_MA, SUN_TRADER, SUN_MA)
                        VALUES (@Assignment_Date, @Meeting_Id,@Lid, @Event_No, @Lux_Trader, @Lux_Ma, @Tab_Trader, @Tab_Ma, @Sun_Trader, @Sun_Ma);";



            _database.Execute(sql, assignments, commandType: CommandType.Text);

            // remove duplicate assignments
            var dupeSql = @"WITH CTE AS(
                    SELECT ASSIGNMENT_DATE, MEETING_ID,LID, EVENT_NO, LUX_TRADER, LUX_MA, TAB_TRADER, TAB_MA, SUN_TRADER, SUN_MA,
                    RN = ROW_NUMBER()OVER(PARTITION BY ASSIGNMENT_DATE, MEETING_ID,LID, EVENT_NO, LUX_TRADER, LUX_MA, TAB_TRADER, TAB_MA, SUN_TRADER, SUN_MA order by LID)
                    FROM dbo.TRADER_ASSIGN
                        )
                    DELETE FROM CTE WHERE RN > 1";

            _database.Execute(dupeSql, assignments, commandType: CommandType.Text);

        }

        public void DeleteAssignments(int traderAssignId)
        {
            var sql = "DELETE FROM TRADER_ASSIGN WHERE TRADER_ASSIGN_ID = @traderAssignId";

            _database.Execute(sql, new { traderAssignId }, commandType: CommandType.Text);
        }
    }

}