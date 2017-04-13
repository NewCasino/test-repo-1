namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Http;
    using Infrastructure;
    using NLog;
    using Services;

    using DTO;

    [RequireAuthentication]
    public class DroEventController : ApiController
    {
        private readonly IDroEventService _droEventService;

        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public DroEventController(IDroEventService droEventService)
        {
            _droEventService = droEventService;
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
                return _droEventService.GetEventMeta(octsCode, meetingDate, eventNumber);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new DroEventMetaResponse() { Success = false, Message = ex.Message };
            }
        }

    }
}