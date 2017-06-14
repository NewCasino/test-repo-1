namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Common;
    using DTO;
    using Models;
    using Repositories;
    using System.Text;
    using System.Globalization;
    using NLog;
    using RubixRacing.Cache;

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

        void UpdateAutoRedistribute(int meetingId, int eventNumber, EventService.Product product,
            EventService.SdpType sdpType, bool isChecked, string currentUser);

        string GetNavigationList();
    }

    public class EventService : IEventService
    {
        public enum Product
        {
            Sun,
            Lux,
            Tab
        }

        public enum SdpType
        {
            Win,
            Place
        }

        private readonly IEventRepository _eventRepository;
        private readonly ICodeService _codeService;
        private readonly ICacheProvider _cacheProvider;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();


        public EventService(IEventRepository eventRepository, ICodeService codeService, ICacheProvider cacheProvider)
        {
            _eventRepository = eventRepository;
            _codeService = codeService;
            _cacheProvider = cacheProvider;
        }

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

        public Event GetEvent(int meetingId, int eventNumber)
        {
            return _eventRepository.GetEvent(meetingId, eventNumber);
        }

        public EventMetaResponse GetEventMeta(int meetingId, int eventNumber)
        {
            var eventMeta = _eventRepository.GetEventMeta(meetingId, eventNumber);

            var result = new EventMetaResponse
            {
                Event = eventMeta,
                Runners = eventMeta.Runners
            };


            return result;
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

        public void UpdateAutoRedistribute(int meetingId, int eventNumber, Product product, SdpType sdpType, bool isChecked, string currentUser)
        {
            _eventRepository.UpdateAutoRedistribute(meetingId, eventNumber, product, sdpType, isChecked, currentUser);
        }

        public string GetNavigationList()
        {
            return _cacheProvider.GetItem(BuildNavigationList,
                new CachePolicy() { AbsoluteExpiration = DateTimeOffset.Now.AddSeconds(3) }, "navigation-list");
        }

        private string BuildNavigationList()
        {
            _logger.Info("Building navigation list");
            var events = _eventRepository.GetNavigationList();
            var venueBuilder = new StringBuilder();

            foreach (var @event in events)
            {
                int eventM2R = @event.M2r;
                if (eventM2R > 99)
                {
                    eventM2R = 99;
                }
                else if (eventM2R < -99)
                {
                    eventM2R = -99;
                }
                var venue =
                    $"{@event.Country}\t{@event.Type}\t{@event.Meeting_Id}\t{HexDate(@event.Start_Time.ToUniversalTime())}\t{@event.Event_No.ToString().PadLeft(2, '0')}\t{TitleCase(@event.Venue.ToLower())}\t{TitleCase(@event.Status.ToLower())}\t{eventM2R}\t{(@event.NoLxb.GetValueOrDefault() ? "1" : "0")}\t{@event.FxCount}\t{@event.ProductEnablementFlag}\n";
                venueBuilder.Append(venue);
            }

            return venueBuilder.ToString();
        }

        private static TextInfo auCulture = new CultureInfo("en-AU", false).TextInfo;
        private string TitleCase(string target)
        {
            return auCulture.ToTitleCase(target); //War And Peace
        }

        private string HexDate(DateTime time)
        {
            var epochTime = time - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return ((int)epochTime.TotalSeconds).ToString("X");
        }
    }
}