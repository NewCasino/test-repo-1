namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Http;
    using DTO;
    using Infrastructure;
    using NLog;
    using Services;
    using System.Net.Http;

    [RequireAuthentication]
    public class EventController : ApiController
    {
        private readonly IEventService _eventService;
        private readonly ISecurityService _securityService;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public EventController(IEventService eventService, ISecurityService securityService)
        {
            _eventService = eventService;
            _securityService = securityService;
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
        public JsonResponseBase UpdateAutoRedistribute(int meetingId, int eventNumber, EventService.Product product,
            EventService.SdpType sdpType, bool isChecked)
        {
            try
            {
                var currentUser = _securityService.GetCurrentUser();
                _eventService.UpdateAutoRedistribute(meetingId, eventNumber, product, sdpType, isChecked, currentUser);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new JsonResponseBase { Success = false, Message = ex.Message };
            }

            return new JsonResponseBase { Success = true };
        }

        [HttpGet]
        public EventMetaResponse EventMeta(int meetingId, int eventNumber)
        {
            try
            {
                return _eventService.GetEventMeta(meetingId, eventNumber);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new EventMetaResponse() { Success = false, Message = ex.Message };
            }            
        }


        [HttpGet]
        public HttpResponseMessage Navigation()
        {
            var response = new HttpResponseMessage();
            response.Content = new StringContent(_eventService.GetNavigationList());
            return response;
        }


    }
}