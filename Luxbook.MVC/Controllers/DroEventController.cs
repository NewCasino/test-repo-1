namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Http;
    using Infrastructure;
    using NLog;
    using Services;

    using DTO;
    using Repositories;

    [RequireAuthentication]
    public class DroEventController : ApiController
    {
        private readonly IDroEventService _droEventService;
        private readonly IDroEventRepository _droEventRepository;

        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public DroEventController(IDroEventService droEventService, IDroEventRepository droEventRepository)
        {
            _droEventService = droEventService;
            _droEventRepository = droEventRepository;
        }

        [HttpGet]
        public DroEventMetaResponse EventMeta(int meetingId, int eventNumber)
        {
            try
            {
                return _droEventService.GetEventMeta(meetingId, eventNumber);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new DroEventMetaResponse() { Success = false, Message = ex.Message };
            }
        }

        [HttpGet]
        public DroEventMetaResponse EventMeta(string octsCode, string meetingDate, int eventNumber)
        {
            try
            {
                int meetingId = _droEventRepository.GetMeetingId(octsCode, meetingDate);
                if ( meetingId > 0) {
                    return _droEventService.GetEventMeta(meetingId, eventNumber);
                }
                return new DroEventMetaResponse() { Success = false, Message = "matching meeting not found" };
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new DroEventMetaResponse() { Success = false, Message = ex.Message };
            }
        }

    }
}