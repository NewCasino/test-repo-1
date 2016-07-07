namespace Luxbook.MVC.Services
{
    using System.Collections.Generic;
    using Models;
    using Repositories;

    public interface IMeetingService
    {
        /// <summary>
        ///     Returns a list of meeting dates in the system. This will not populate any other meeting info atm.
        /// </summary>
        /// <returns></returns>
        List<Meeting> GetAllMeetingDates();
    }

    public class MeetingService : IMeetingService
    {
        private readonly IMeetingRepository _meetingRepository;

        public MeetingService(IMeetingRepository meetingRepository)
        {
            _meetingRepository = meetingRepository;
        }

        /// <summary>
        ///     Returns a list of meeting dates in the system. This will not populate any other meeting info atm.
        /// </summary>
        /// <returns></returns>
        public List<Meeting> GetAllMeetingDates()
        {
            return _meetingRepository.GetAllMeetingDates();
        }

    }
}