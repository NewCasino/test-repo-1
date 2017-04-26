namespace Luxbook.MVC.Repositories
{
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface IMeetingRepository
    {
        /// <summary>
        ///     Returns a list of meeting dates in the system. This will not populate any other meeting info atm.
        /// </summary>
        /// <returns></returns>
        List<Meeting> GetAllMeetingDates();
    }

    public class MeetingRepository : IMeetingRepository
    {
        private readonly IDatabase _database;

        public MeetingRepository(IDatabase database)
        {
            _database = database;
        }

        /// <summary>
        ///     Returns a list of meeting dates in the system. This will not populate any other meeting info atm.
        /// </summary>
        /// <returns></returns>
        public List<Meeting> GetAllMeetingDates()
        {
            return
                _database.Query<Meeting>(
                    "SELECT DISTINCT MEETING_DATE as MeetingDate " +
                    "FROM MEETING(nolock) " +
                    "WHERE MEETING_DATE IS NOT NULL " +
                    "ORDER BY MEETING_DATE DESC",
                    commandType: CommandType.Text)
                    .ToList();
        }
    }
}