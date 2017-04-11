namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Common;
    using Models;
    using Repositories;

    using DTO;

    public interface IDroEventService
    {
        DroEventMetaResponse GetEventMeta(int meetingId, int eventNumber);

    }

    public class DroEventService : IDroEventService
    {

        private readonly IDroEventRepository _droEventRepository;
 
        public DroEventService(IDroEventRepository droEventRepository)
        {
            _droEventRepository = droEventRepository;
        }

        public DroEventMetaResponse GetEventMeta(int meetingId, int eventNumber)
        {
            var droEventMeta = _droEventRepository.GetEventMeta(meetingId, eventNumber);

            var result = new DroEventMetaResponse
            {
                Event = droEventMeta
            };


            return result;
        }

    }
}