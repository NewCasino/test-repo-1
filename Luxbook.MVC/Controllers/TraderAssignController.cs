namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Http;
    using DTO;
    using Infrastructure;
    using NLog;
    using Services;
    using System.Collections.Generic;

    [RequireAuthentication]
    public class TraderAssignController : ApiController
    {
        private readonly ITraderAssignService _traderAssignService;
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public TraderAssignController(ITraderAssignService traderAssignService)
        {
            _traderAssignService = traderAssignService;
        }

        [HttpGet]
        public TraderAssignMetaResponse Assignments(string meetingDate)
        {
            try
            {
                return _traderAssignService.GetAssignments(meetingDate);
            }
            catch (Exception ex)
            {
                _logger.Error(ex);
                return new TraderAssignMetaResponse() { Success = false, Message = ex.Message };
            }
        }

        [HttpGet]
        public EventAssignMetaResponse AssignmentsByDate(string mode, string date)
        {
            return _traderAssignService.GetAssignmentsByDate(mode, date);
        }

        [HttpPost]
        public TraderAssignMetaResponse Assignments(TraderAssignPostDataDto postData)
        {
            return _traderAssignService.SaveAssignments(postData);
        }

        [HttpGet]
        public void AssignmentsForMeeting(DateTime meetingDate)
        {
            
        }


        [HttpPost]
        public void DeleteAssignment([FromBody]int traderAssignId)
        {
            _traderAssignService.DeleteAssignment(traderAssignId);
        }
    }
}