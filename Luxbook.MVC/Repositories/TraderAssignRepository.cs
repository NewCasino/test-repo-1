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
        List<EventAssignMetaResponse> GetAssignmentsByDate(string Mode, string Date);
        void SaveAssignments(string meetingDate, DtoSelectedEvent dtoEvent, List<DtoAssignments> dtoAssignments);
        void SaveAssignment(string meetingDate, DtoSelectedEvent dtoEvent, string assignmentDate, DtoAssignedTraders dtoTraders);
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
                                            LEFT JOIN SYS_BETTEKK sb ON (m.COUNTRY=sb.COUNTRY AND M.TYPE=SB.TYPE and sb.VENUE LIKE Cast(m.VENUE as nvarchar(55)) +  '%')
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
                                            WHERE ta.Meeting_Date = @meetingDate
                                            ORDER BY MEETING_ID, EVENT_NO;",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var assignResponse = new TraderAssignMetaResponse {
                Meetings = meetings.ToList(),
                Traders = traders.ToList(),
                Assignments = assignments.ToList(),
            };

            return assignResponse;

        }

        public void SaveAssignments(string meetingDate, DtoSelectedEvent dtoEvent, List<DtoAssignments> dtoAssignments)
        {
            foreach (DtoAssignments i in dtoAssignments)
            {
                this.SaveAssignment(meetingDate, dtoEvent, i.AssignedDate, i.AssignedTraders);
            }
        }

        public void SaveAssignment(string meetingDate, DtoSelectedEvent dtoEvent, string assignmentDate, DtoAssignedTraders dtoTraders)
        {
            var pk = _database.Query<int>("SELECT TRADER_ASSIGN_ID FROM TRADER_ASSIGN WHERE MEETING_ID=@MeetingId AND EVENT_NO=@EventNo AND ASSIGNED_DATE=@AssignedDate;", 
                    new {
                        MeetingId = dtoEvent.MeetingId,
                        EventNo = dtoEvent.EventNo,
                        AssignedDate = assignmentDate
                    }, commandType: CommandType.Text).FirstOrDefault();

            // update existing assignments for meeting_id+event_no
            if (pk > 0)
            {
                var sqlUpdate = @"UPDATE TRADER_ASSIGN 
                                  SET LUX_TRADER=@LuxTrader, LUX_MA=@LuxMa,
                                  SET TAB_TRADER=@TabTrader, TAB_MA=@TabMa,
                                  SET SUN_TRADER=@SunTrader, SUN_MA=@SunMa
                                  WHERE TRADER_ASSIGN_ID = @traderAssignId;
                ";
                _database.Execute(sqlUpdate,
                    new
                    {
                        traderAssignId = pk,
                        LuxTrader = dtoTraders.LuxTrader,
                        LuxMa = dtoTraders.LuxMa,
                        TabTrader = dtoTraders.TabTrader,
                        TabMa = dtoTraders.TabMa,
                        SunTrader = dtoTraders.SunTrader,
                        SunMa = dtoTraders.SunMa
                    },
                    commandType: CommandType.Text);
                return;
            }

            // insert new assignments for meeting_id
            var sql = @"INSERT INTO TRADER_ASSIGN 
                        (MEETING_DATE, ASSIGNED_DATE, MEETING_ID, EVENT_NO, LUX_TRADER, LUX_MA, TAB_TRADER, TAB_MA, SUN_TRADER, SUN_MA)
                        VALUES (@meetingDate, @AssignedDate, @MeetingId, @EventNo, @LuxTrader, @LuxMa, @TabTrader, @TabMa, @SunTrader, @SunMa);
            ";
            _database.Execute(sql,
                new
                {
                    meetingDate,
                    MeetingId = dtoEvent.MeetingId,
                    EventNo = dtoEvent.EventNo,
                    AssignedDate = assignmentDate,
                    LuxTrader = dtoTraders.LuxTrader,
                    LuxMa = dtoTraders.LuxMa,
                    TabTrader = dtoTraders.TabTrader,
                    TabMa = dtoTraders.TabMa,
                    SunTrader = dtoTraders.SunTrader,
                    SunMa = dtoTraders.SunMa
                },
                commandType: CommandType.Text);

        }

        public List<EventAssignMetaResponse> GetAssignmentsByDate(string Mode, string Date)
        {
            // note:- this may change in future
            var sql = (Mode == "meeting" ?
                            @"SELECT ta.Meeting_Date, 
                                    e.Meeting_id, e.Event_No, ta.Assigned_Date, e.Start_Time, m.Country, m.Type, e.Name, sb.Region, m.Venue,
                                    ta.Lux_Trader, ta.Tab_Trader, ta.Sun_Trader, ta.Lux_Ma, ta.Tab_Ma, ta.Sun_Ma
                                    FROM dbo.TRADER_ASSIGN as ta
                                    INNER JOIN EVENT_TAB e ON (ta.MEETING_ID=e.MEETING_ID and ta.EVENT_NO=e.EVENT_NO)
                                    INNER JOIN MEETING_TAB m ON (ta.MEETING_ID=m.MEETING_ID)
                                    LEFT JOIN SYS_BETTEKK sb ON (m.COUNTRY=sb.COUNTRY AND m.TYPE=SB.TYPE and sb.VENUE LIKE Cast(m.VENUE as nvarchar(55)) +  '%')
                                    WHERE ta.Meeting_Date = @Date
                                    ORDER BY 2, 3, 4;"
                        :
                            @"SELECT ta.Meeting_Date, 
                                    e.Meeting_id, e.Event_No, ta.Assigned_Date, e.Start_Time, m.Country, m.Type, e.Name, sb.Region, m.Venue,
                                    ta.Lux_Trader, ta.Tab_Trader, ta.Sun_Trader, ta.Lux_Ma, ta.Tab_Ma, ta.Sun_Ma
                                    FROM dbo.TRADER_ASSIGN as ta
                                    INNER JOIN EVENT_TAB e ON (ta.MEETING_ID=e.MEETING_ID and ta.EVENT_NO=e.EVENT_NO)
                                    INNER JOIN MEETING_TAB m ON (ta.MEETING_ID=m.MEETING_ID)
                                    LEFT JOIN SYS_BETTEKK sb ON (m.COUNTRY=sb.COUNTRY AND m.TYPE=SB.TYPE and sb.VENUE LIKE Cast(m.VENUE as nvarchar(55)) +  '%')
                                    WHERE ta.Assigned_Date = @Date
                                    ORDER BY 2, 3, 4;"
                );
            var assignments =
                _database.Query<EventAssignMetaResponse>(sql,
                    new
                    {
                        Date
                    }, commandType: CommandType.Text);

            return assignments.ToList();

        }
    }

}