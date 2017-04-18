namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface IDroEventRepository
    {
        DroEventMeta GetEventMeta(int meetingId, int eventNumber);
        int GetMeetingId(string octsCode, string meetingDate);
    }

    public class DroEventRepository : IDroEventRepository
    {
        private readonly IDatabase _database;

        public DroEventRepository(IDatabase database)
        {
            _database = database;
        }

        public DroEventMeta GetEventMeta(int meetingId, int eventNumber)
        {
            var droEventMeta =
                _database.Query<DroEventMeta>(@"SELECT mv.Meeting_Id, mv.Event_No, mv.Start_Time, mv.Type,
                                            mv.Country, mv.Venue, mv.Name, mv.Btk_Id, 
                                            m.Wift_Mtg_Id, m.Fxo_Id, m.Pa_Mtg_Id, 
                                            e.Wift_Evt_Id, e.Wift_Src_Id, e.Wp_EventId, e.Pa_Evt_Id, e.Gtx_Id, e.Bfr_Mkt_Id 
                                            FROM dbo.MEETING_VIEW as mv
                                            INNER JOIN dbo.MEETING as m ON (mv.MEETING_ID = m.MEETING_ID)
                                            INNER JOIN dbo.EVENT as e ON (mv.MEETING_ID = e.MEETING_ID AND mv.EVENT_NO = e.EVENT_NO)
                                            WHERE mv.EVENT_NO = @eventNumber and mv.MEETING_ID = @meetingId",
                    new
                    {
                        eventNumber,
                        meetingId
                    }, commandType: CommandType.Text).FirstOrDefault();

            var droRunnerMeta =
                _database.Query<DroRunnerMeta>(@"SELECT MEETING_ID, EVENT_NO, RUNNER_NO, NAME, SCR, TAB_PROP,
                                            Fx_Bob, Fx_Wow, B1y_Fw, Ezy_Fw, Lad_Fw, Spb_Fw, Ias_Fw, Top_Fw, Qld_Fw, 
                                            Uni_Fw, Apn_Fw, Bfr_Fw_B1, Bfr_Fw_L1, Pm_Dvp, Bfr_Tmc, Bfr_Lpt, Aus_Tw,
                                            Vic_Tw, Nsw_Tw, Qld_Tw, Sun_Sdp, Tab_Sdp, Lux_Sdp,
                                            HST_VT, HST_VQ, HST_VX, RDB_TW
                                            FROM dbo.RUNNER_TAB 
                                            WHERE EVENT_NO = @eventNumber and MEETING_ID = @meetingId
                                            ORDER BY RUNNER_NO",
                    new
                    {
                        eventNumber,
                        meetingId
                    }, commandType: CommandType.Text);

            if (droEventMeta != null)
            {
                droEventMeta.Runners = droRunnerMeta.ToList();
            }

            return droEventMeta;

        }

        public int GetMeetingId(string octsCode, string meetingDate)
        {
            int meetingId = _database.Query<int>(@"SELECT mt.Meeting_Id
                                            FROM dbo.MEETING_TAB as mt
                                            WHERE mt.MEETING_DATE = @meetingDate
                                            AND mt.BTK_ID = @octsCode",
                                new
                                {
                                    octsCode,
                                    meetingDate
                                }, commandType: CommandType.Text).FirstOrDefault();
            return meetingId;
        }

    }
}