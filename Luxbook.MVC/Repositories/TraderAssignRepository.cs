namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;
    using Services;

    using DTO;

    public interface ITraderAssignRepository
    {
        TraderAssignMetaResponse GetAssignments(string meetingDate);
        void SaveAssignment(string meetingDate, int meetingId, string env, string traders, string analysts);
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
                                            m.Country, m.Type, m.Venue, m.Btk_Id, m.Events, m.Wift_Mtg_Id
                                            FROM dbo.MEETING_TAB as m
                                            WHERE m.MEETING_Date = @meetingDate
                                            ORDER BY m.Venue",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var events =
                _database.Query<EventTags>(@"SELECT e.Meeting_id, e.Event_No, e.Start_Time, e.Name
                                            FROM dbo.EVENT_TAB as e
                                            INNER JOIN dbo.MEETING_TAB as m ON (e.meeting_id=m.meeting_id)                                            
                                            WHERE m.MEETING_Date = @meetingDate",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var traders =
                _database.Query<TraderTags>(@"SELECT t.Lid, t.Name,
                                            t.Lux, t.Tab, t.Sun
                                            FROM dbo.TRADER as t",
                    new 
                    {
                    }, commandType: CommandType.Text);

            var assignments =
                _database.Query<TraderAssign>(@"SELECT ta.*
                                            FROM dbo.TRADER_ASSIGN as ta
                                            WHERE ta.Meeting_Date = @meetingDate",
                    new
                    {
                        meetingDate
                    }, commandType: CommandType.Text);

            var assignResponse = new TraderAssignMetaResponse {
                Meetings = meetings.ToList(),
                Events = events.ToList(),
                Traders = traders.ToList(),
                Assignments = assignments.ToList(),
            };

            return assignResponse;

        }

        public void SaveAssignment(string meetingDate, int meetingId, string env, string traders, string analysts)
        {
            var pk = _database.Query<int>("SELECT TRADER_ASSIGN_ID FROM TRADER_ASSIGN WHERE MEETING_ID=@MeetingId;", 
                    new {
                        MeetingId = meetingId
                        }, commandType: CommandType.Text).FirstOrDefault();

            // update existing assignments for meeting_id
            if (pk > 0)
            {
                var sqlUpdate = "UPDATE TRADER_ASSIGN SET " + env + "_TRADER=@trader, " + env + "_MA=@ma " +
                          "WHERE TRADER_ASSIGN_ID = @traderAssignId;";
                _database.Execute(sqlUpdate,
                    new
                    {
                        traderAssignId = pk,
                        trader = traders,
                        ma = analysts
                    },
                    commandType: CommandType.Text);
                return;
            }

            // insert new assignments for meeting_id
            var sql = "INSERT INTO TRADER_ASSIGN (MEETING_DATE, MEETING_ID, " + env + "_TRADER, " + env + "_MA) " +
                      "VALUES (@meetingDate, @meetingId, @traders, @analysts);";
            _database.Execute(sql,
                new
                {
                    meetingDate,
                    meetingId,
                    traders,
                    analysts
                },
                commandType: CommandType.Text);

        }

    }
}