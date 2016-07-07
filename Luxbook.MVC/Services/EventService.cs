namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Common;
    using Models;
    using Repositories;

    public interface IEventService
    {
        List<RunnerLiability> GetAllEventLiabilities();

        /// <summary>
        ///     Get all events from meetings that start at a particular date
        /// </summary>
        /// <param name="meetingDate"></param>
        /// <param name="internationalsOnly"></param>
        /// <param name="raceType"></param>
        /// <returns></returns>
        List<Event> GetAllEvents(DateTime meetingDate, bool internationalsOnly, Enums.RaceType raceType);

        Event GetEvent(int meetingId, int eventNumber);

        /// <summary>
        /// Sets the reduced staking flag on the vent level
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        void SetReducedStaking(int meetingId, int eventNumber);
    }

    public class EventService : IEventService
    {
        private readonly IEventRepository _eventRepository;
        private readonly ICodeService _codeService;

        public List<RunnerLiability> GetAllEventLiabilities()
        {
            return _eventRepository.GetAllEventLiabilities();
        }

        /// <summary>
        ///     Get all events from meetings that start at a particular date
        /// </summary>
        /// <param name="meetingDate"></param>
        /// <param name="internationalsOnly"></param>
        /// <param name="raceType"></param>
        /// <returns></returns>
        public List<Event> GetAllEvents(DateTime meetingDate, bool internationalsOnly, Enums.RaceType raceType)
        {
            return _eventRepository.GetAllEvents(meetingDate, internationalsOnly, _codeService.GetCodeFromRaceType(raceType));
        }

        public EventService(IEventRepository eventRepository, ICodeService codeService)
        {
            _eventRepository = eventRepository;
            _codeService = codeService;
        }

        public Event GetEvent(int meetingId, int eventNumber)
        {
            return _eventRepository.GetEvent(meetingId, eventNumber);
        }

        /// <summary>
        /// Sets the reduced staking flag on the vent level
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        public void SetReducedStaking(int meetingId, int eventNumber)
        {
            _eventRepository.SetReducedStaking(meetingId, eventNumber);
        }
    }
}