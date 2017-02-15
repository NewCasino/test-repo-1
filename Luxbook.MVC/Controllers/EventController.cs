namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Http;
    using DTO;
    using Infrastructure;
    using NLog;
    using Services;

    [RequireAuthentication]
    public class EventController : ApiController
    {
        private readonly IEventService _eventService;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public EventController(IEventService eventService)
        {
            _eventService = eventService;
        }

        [HttpGet]
        public JsonResponseBase UpdatePlacePays(int meetingId, int eventNumber, EventService.Product product,
            int? placePays)
        {
            try
            {
                _eventService.UpdatePlacePays(meetingId, eventNumber, product, placePays);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new JsonResponseBase {Success = false, Message = ex.Message};
            }

            return new JsonResponseBase {Success = true};
        }
        
        [HttpGet]
        public Object EventMeta(int meetingId, int eventNumber)
        {
            try
            {
                return _eventService.GetEventMeta(meetingId, eventNumber);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new JsonResponseBase { Success = false, Message = ex.Message };
            }            
        }

    }
}