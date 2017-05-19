using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Repositories
{
    using System.Data;
    using Infrastructure;
    using Services;

    public interface IRunnerRepository
    {
        void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser);
        void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType, decimal? boundary, string currentUser);
        void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser);
        void UpdatePropIds(List<RunnerUpdateParameters> parameters,
            string currentUser);
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
            var priorityColumns = new List<string>();

            switch (rollType)
            {
                case "SDP_ADJ":
                    type = "Lux SDP roll";
                    priorityColumns.Add("LUX");
                    break;
                case "SDP_ADJ_SUN":
                    type = "SUN SDP roll";
                    priorityColumns.Add("SUN");
                    break;
                case "SDP_ADJ_MASTER":
                    type = "Master  SDP roll";
                    priorityColumns.AddRange(new[] { "LUX", "SUN", "TAB" });
                    break;
                case "SDP_ADJ_TAB":
                    type = "TAB SDP roll";
                    priorityColumns.Add("TAB");
                    break;
                case "PLACE_SDP_ADJ_LUX":
                    type = "Lux Place roll";
                    priorityColumns.Add("LUX");

                    break;
                case "PLACE_SDP_ADJ_SUN":
                    type = "Sun Place roll";
                    priorityColumns.Add("SUN");
                    break;
                case "PLACE_SDP_ADJ_MASTER":
                    type = "Master Place roll";
                    priorityColumns.AddRange(new[] { "LUX", "SUN", "TAB" });

                    break;
                case "PLACE_SDP_ADJ_TAB":
                    type = "TAB Place roll";
                    priorityColumns.Add("TAB");
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(rollType), rollType, "Roll type not valid");
            }
            var notification = $"[{DateTime.Now.ToString("h:mm:ss tt")}] {currentUser} set {type} to {roll} for runner {runnerNumber}<br/>";
            string priorityUpdates = string.Empty;
            if (priorityColumns.Any())
            {
                priorityUpdates = "," + string.Join(",", priorityColumns.Select(x => $"{x}_PRIORITY_UPDATE = 1"));
            }
            var sql =
                string.Format("UPDATE RUNNER_TAB SET {0} = @roll WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber AND RUNNER_NO = @runnerNumber;" +
                              "UPDATE EVENT_TAB SET NOTIFICATIONS = ISNULL(NOTIFICATIONS,'') + @notification {1}  WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber;", rollType, priorityUpdates);
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
            var priorityColumns = new List<string>();

            switch (boundaryType)
            {
                case "SDP_MIN":
                    type = "Lux SDP minimum";
                    priorityColumns.AddRange(new[] { "LUX", "SUN" });
                    break;
                case "SDP_MAX":
                    type = "Lux SDP maximum";
                    priorityColumns.AddRange(new[] { "LUX", "SUN" });
                    break;
                case "SDP_MIN_TAB":
                    type = "TAB SDP minimum";
                    priorityColumns.Add("TAB");
                    break;
                case "SDP_MAX_TAB":
                    type = "TAB SDP maximum";
                    priorityColumns.Add("TAB");
                    break;
                case "SDP_MIN_SUN":
                    type = "SUN SDP minimum";
                    priorityColumns.AddRange(new[] { "SUN" });
                    break;
                case "SDP_MAX_SUN":
                    type = "SUN SDP maximum";
                    priorityColumns.AddRange(new[] { "SUN" });
                    break;
                case "SDP_MIN_MASTER":
                    type = "Master SDP minimum";
                    priorityColumns.AddRange(new[] { "LUX", "SUN", "TAB" });
                    break;
                case "SDP_MAX_MASTER":
                    type = "Master SDP maximum";
                    priorityColumns.AddRange(new[] { "LUX", "SUN", "TAB" });
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(boundaryType), boundaryType, "Boundary type not valid");
            }
            var notification = $"[{DateTime.Now.ToString("h:mm:ss tt")}] {currentUser} set {type} to {boundary} for runner {runnerNumber}<br/>";
            string priorityUpdates = string.Empty;
            if (priorityColumns.Any())
            {
                priorityUpdates = "," + string.Join(",", priorityColumns.Select(x => $"{x}_PRIORITY_UPDATE = 1"));
            }

            var sql = string.Format("UPDATE RUNNER_TAB SET {0} = @boundary WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber AND RUNNER_NO = @runnerNumber;" +
                             "UPDATE EVENT_TAB SET NOTIFICATIONS = ISNULL(NOTIFICATIONS,'') + @notification {1} WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber;", boundaryType, priorityUpdates);
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

        public void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser)
        {
            var sql = (!unscratch) ? "UPDATE RUNNER SET SCR=1, SCRATCH=3, SCR_TIMESTAMP = getdate() " :
                                     "UPDATE RUNNER SET SCR=0, SCRATCH=0, SCR_TIMESTAMP = NULL ";
            sql += "WHERE MEETING_ID = @meetingId AND EVENT_NO = @eventNumber AND RUNNER_NO = @runnerNumber;";
            _database.Execute(sql,
                new
                {
                    meetingId,
                    eventNumber,
                    runnerNumber
                },
                commandType: CommandType.Text
            );
        }

        public void UpdatePropIds(List<RunnerUpdateParameters> parameters, string currentUser)
        {
            var sql = "UPDATE RUNNER_TAB SET TAB_PROP = @PropId, LS_EVENT_ID = @LsportsEventId " +
                      "WHERE MEETING_ID = @MeetingId AND EVENT_NO = @EventNumber AND RUNNER_NO = @RunnerNumber;";
            _database.Execute(sql,
               parameters,
                commandType: CommandType.Text
            );
        }
    }

}