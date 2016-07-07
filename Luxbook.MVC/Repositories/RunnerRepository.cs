using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Repositories
{
    using System.Data;
    using Infrastructure;

    public interface IRunnerRepository
    {
        void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser);
        void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType, decimal? boundary, string currentUser);
    }

    public class RunnerRepository : IRunnerRepository
    {
        private readonly IDatabase _database;
        public RunnerRepository(IDatabase database)
        {
            _database = database;
        }

        public void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser)
        {
            string type = "";
            switch (rollType)
            {
                case "SDP_ADJ":
                    type = "Lux SDP roll";
                    break;
                case "SDP_ADJ_TAB":
                    type = "TAB SDP roll";
                    break;
                case "PLACE_SDP_ADJ_LUX":
                    type = "Lux Place roll";
                    break;
                case "PLACE_SDP_ADJ_TAB":
                    type = "TAB Place roll";
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(rollType), rollType, "Roll type not valid");
            }
            var notification = $"[{DateTime.Now.ToString("h:mm:ss tt")}] {currentUser} set {type} to {roll} for runner {runnerNumber}<br/>";
            var sql =
                string.Format("UPDATE RUNNER_TAB SET {0} = @roll WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber AND RUNNER_NO = @runnerNumber;" +
                              "UPDATE EVENT_TAB SET NOTIFICATIONS = ISNULL(NOTIFICATIONS,'') + @notification  WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber;", rollType);
            _database.Execute(sql, new
            {
                meetingId,
                eventNumber,
                runnerNumber,
                rollType,
                roll,
                notification,
            }, commandType: CommandType.Text);
        }

        public void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType, decimal? boundary, string currentUser)
        {
            string type = "";

            switch (boundaryType)
            {
                case "SDP_MIN":
                    type = "Lux SDP minimum";
                    break;
                case "SDP_MAX":
                    type = "Lux SDP maximum";
                    break;
                case "SDP_MIN_TAB":
                    type = "TAB SDP minimum";
                    break;
                case "SDP_MAX_TAB":
                    type = "TAB SDP maximum";
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(boundaryType), boundaryType, "Boundary type not valid");
            }
            var notification = $"[{DateTime.Now.ToString("h:mm:ss tt")}] {currentUser} set {type} to {boundary} for runner {runnerNumber}<br/>";

            var sql = string.Format("UPDATE RUNNER_TAB SET {0} = @boundary WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber AND RUNNER_NO = @runnerNumber;" +
                             "UPDATE EVENT_TAB SET NOTIFICATIONS = ISNULL(NOTIFICATIONS,'') + @notification WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber;", boundaryType );
            _database.Execute(sql, new
            {
                meetingId,
                eventNumber,
                runnerNumber,
                boundary,
                currentUser,
                notification
            }, commandType: CommandType.Text);
        }
    }
}