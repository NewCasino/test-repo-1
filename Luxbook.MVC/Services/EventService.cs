namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Common;
    using Models;
    using Repositories;
    using Repositories.Responses;

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

        /// <summary>
        ///     Get event meta data for use by the RR gui prop id edit form
        /// </summary>
        EventMetaResponse GetEventMeta(int meetingId, int eventNumber);

        Event GetEvent(int meetingId, int eventNumber);

        /// <summary>
        /// Sets the reduced staking flag on the vent level
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        void SetReducedStaking(int meetingId, int eventNumber);

        /// <summary>
        /// 
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        /// <param name="product"></param>
        /// <param name="places">Overrides how many places to payout, or to reset to the default calculated value</param>
        void UpdatePlacePays(int meetingId, int eventNumber, EventService.Product product, int? places);
    }

    public class EventService : IEventService
    {
        public enum Product
        {
            Sun,
            Lux,
            Tab
        }

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

        public EventMetaResponse GetEventMeta(int meetingId, int eventNumber)
        {
            return _eventRepository.GetEventMeta(meetingId, eventNumber);
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="meetingId"></param>
        /// <param name="eventNumber"></param>
        /// <param name="product"></param>
        /// <param name="places">Overrides how many places to payout, or to reset to the default calculated value</param>
        public void UpdatePlacePays(int meetingId, int eventNumber, Product product, int? places)
        {
            _eventRepository.UpdatePlacePays(meetingId, eventNumber, product, places);
        }
    }
}