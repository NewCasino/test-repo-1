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

    public interface IEventRepository
    {
        List<RunnerLiability> GetAllEventLiabilities();
        List<Event> GetAllEvents(DateTime meetingDate, bool internationalsOnly, string raceType);
        Event GetEvent(int meetingId, int eventNumber);
        EventMeta GetEventMeta(int meetingId, int eventNumber);

        /// <summary>
        /// Sets the reduced staking flag on the vent level
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        void SetReducedStaking(int meetingId, int eventNumber);

        void UpdatePlacePays(int meetingId, int eventNumber, EventService.Product product, int? places);

        void UpdateAutoRedistribute(int meetingId, int eventNumber, EventService.Product product, EventService.SdpType sdpType, bool isChecked, string currentUser);
        void UpdateEventMeta(EventMeta metaData);
    }

    public class EventRepository : IEventRepository
    {
        private readonly IDatabase _database;

        public EventRepository(IDatabase database)
        {
            _database = database;
        }

        public List<RunnerLiability> GetAllEventLiabilities()
        {
            return _database.Query<RunnerLiability>("[sp_GetAllFutureRunLiability]").ToList();
        }

        public List<Event> GetAllEvents(DateTime meetingDate, bool internationalsOnly, string raceType)
        {
            var sql = @"SELECT 	
                            ET.Obsv, 
				            ET.Trader,
				            ET.Comment,
				            ET.[Status],
				            ET.Start_Time,
				            ET.Name,
                            ET.MEETING_ID,
                            ET.EVENT_NO,
                            MT.VENUE, MT.COUNTRY, MT.TYPE as RaceTypeCode 
                        FROM EVENT_TAB ET 
                        INNER JOIN MEETING_TAB MT ON MT.MEETING_ID = ET.MEETING_ID 
                        WHERE MT.MEETING_DATE = @meetingDate AND MT.TYPE = @raceType";

            if (internationalsOnly)
            {
                sql += " AND COUNTRY NOT in ('AU','NZ')";
            }
            else
            {
                sql += " AND COUNTRY in ('AU','NZ')";
            }

            return
                _database.Query<Event>(
                    sql,
                    new
                    {
                        meetingDate,
                        raceType
                    }, commandType: CommandType.Text).ToList();
        }

        public Event GetEvent(int meetingId, int eventNumber)
        {
            return
                _database.Query<Event>(@"SELECT MT.MEETING_ID, ET.EVENT_NO, MT.TYPE as RaceTypeCode, MT.TAB_SELL_CODE AS SellCode  
                                            FROM EVENT_TAB ET
                                            INNER JOIN MEETING_TAB MT ON MT.MEETING_ID = ET.MEETING_ID
                                            WHERE ET.EVENT_NO = @eventNumber and MT.MEETING_ID = @meetingId",
                new
                {
                    eventNumber,
                    meetingId
                }, commandType: CommandType.Text).FirstOrDefault();
        }

        public EventMeta GetEventMeta(int meetingId, int eventNumber)
        {
            var eventMeta =
                _database.Query<EventMeta>(@"SELECT e.Meeting_Id, e.Event_No, e.Start_Time, m.Type,
                                            m.Country, m.Venue, e.Name, m.Btk_Id, 
                                            m.Wift_Unq_Mtg_Id, m.Fxo_Id, m.Pa_Mtg_Id, 
                                            e.Wift_Unq_Evt_Id, e.Wift_Src_Id, e.Wp_EventId, e.Pa_Evt_Id, e.Gtx_Id, e.Bfr_Mkt_Id , e.Bfr_Mkt_Id_Fp,
                                            e.Book_Spec_id, e.Match_Spec_Id
                                            FROM  dbo.MEETING_TAB as m with (nolock) 
                                            INNER JOIN dbo.EVENT_TAB as e with (nolock)  ON (m.MEETING_ID = e.MEETING_ID AND e.EVENT_NO = e.EVENT_NO)
                                            WHERE e.EVENT_NO = @eventNumber and e.MEETING_ID = @meetingId",
                    new
                    {
                        eventNumber,
                        meetingId
                    }, commandType: CommandType.Text).FirstOrDefault();

            var runnerMeta =
                _database.Query<RunnerMeta>(@"SELECT MEETING_ID, EVENT_NO, RUNNER_NO, NAME, SCR, TAB_PROP , Ls_Event_id
                                            FROM dbo.RUNNER_TAB
                                            WHERE EVENT_NO = @eventNumber and MEETING_ID = @meetingId
                                            ORDER BY RUNNER_NO",
                    new
                    {
                        eventNumber,
                        meetingId
                    }, commandType: CommandType.Text);

            if (eventMeta != null)
            {
                eventMeta.Runners = runnerMeta.ToList();
                eventMeta.Ls_Event_Id = eventMeta.Runners.First().Ls_Event_Id;
            }

            return eventMeta;

        }

        public void UpdateEventMeta(EventMeta metaData)
        {
            _database.Execute($"UPDATE EVENT_TAB SET BFR_MKT_ID = @Bfr_Mkt_Id , BFR_MKT_ID_FP = @Bfr_Mkt_Id_Fp, BOOK_SPEC_ID = @Book_Spec_Id , MATCH_SPEC_ID = @Match_Spec_Id WHERE MEETING_ID = @Meeting_Id AND EVENT_NO = @Event_No",
                metaData, commandType: CommandType.Text);
        }

        /// <summary>
        /// Sets the reduced staking flag on the vent level
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        public void SetReducedStaking(int meetingId, int eventNumber)
        {
            _database.Execute("UPDATE EVENT_TAB SET RDC_TPM = 1 WHERE EVENT_NO = @eventNumber and MEETING_ID = @meetingId", new
            {
                meetingId,
                eventNumber
            }, commandType: CommandType.Text);
        }

        public void UpdatePlacePays(int meetingId, int eventNumber, EventService.Product product, int? places)
        {
            var sql =
                "UPDATE EVENT_TAB SET {0}_PLACE_PAYS={1} WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber";


            sql = string.Format(sql, product.ToString(), places.HasValue ? places.Value.ToString() : "null");

            _database.Execute(sql, new { meetingId, eventNumber }, commandType: CommandType.Text);

        }

        public void UpdateAutoRedistribute(int meetingId, int eventNumber, EventService.Product product,
            EventService.SdpType sdpType, bool isChecked, string currentUser)
        {
            // Update relevant priority flag
            var priorityColumns = new List<string>();
            switch (product)
            {
                case EventService.Product.Lux:
                    priorityColumns.Add("LUX");
                    break;
                case EventService.Product.Sun:
                    priorityColumns.Add("SUN");
                    break;
                case EventService.Product.Tab:
                    priorityColumns.Add("TAB");
                    break;
                
                default:
                    throw new ArgumentOutOfRangeException("Product not valid");
            }

            var state = isChecked ? "ON" : "OFF";
            var notification = $"[{DateTime.Now.ToString("h:mm:ss tt")}] {currentUser} turned {product} {sdpType} auto-redistribute {state}<br/>";

            string priorityUpdates = string.Empty;
            if (isChecked && priorityColumns.Any())
            {
                priorityUpdates = "," + string.Join(",", priorityColumns.Select(x => $"{x}_PRIORITY_UPDATE = 1"));
            }


            var columnName = $"AUTO_DIST_{product}_{sdpType}_SDP";
            var sql =
                $"UPDATE EVENT_TAB SET {columnName}=@isChecked, NOTIFICATIONS = ISNULL(NOTIFICATIONS,'') + @notification {priorityUpdates} WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber";

            _database.Execute(sql, new { meetingId, eventNumber, isChecked, notification }, commandType: CommandType.Text);

        }
    }
}