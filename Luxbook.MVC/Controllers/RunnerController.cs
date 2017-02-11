using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Luxbook.MVC.Controllers
{
    using DTO;
    using Infrastructure;
    using Newtonsoft.Json.Linq;
    using Services;

    [RequireAuthenticationWebApi]
    public class RunnerController : ApiController
    {
        private readonly IRunnerService _runnerService;
        private readonly ISecurityService _securityService;

        public RunnerController(IRunnerService runnerService, ISecurityService securityService)
        {
            _runnerService = runnerService;
            _securityService = securityService;
        }


        [HttpGet]
        public JsonResponseBase Roll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll)
        {
            var currentUser = _securityService.GetCurrentUser();
            _runnerService.UpdateRunnerRoll(meetingId, eventNumber, runnerNumber, rollType, roll, currentUser);

            return new JsonResponseBase() { Success = true, Message = "Roll updated" };
        }

        [HttpGet]
        public JsonResponseBase Boundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType,
            decimal? boundary)
        {
            var currentUser = _securityService.GetCurrentUser();

            _runnerService.UpdateRunnerBoundary(meetingId, eventNumber, runnerNumber, boundaryType, boundary, currentUser);

            return new JsonResponseBase() { Success = true, Message = "Boundary updated" };

        }

        [HttpGet]
        public JsonResponseBase Scratch(int meetingId, int eventNumber, int runnerNumber)
        {
            var currentUser = _securityService.GetCurrentUser();

            _runnerService.ScratchRunner(meetingId, eventNumber, runnerNumber, false, currentUser);

            return new JsonResponseBase() { Success = true, Message = "Runner scratched" };

        }

        [HttpGet]
        public JsonResponseBase UnScratch(int meetingId, int eventNumber, int runnerNumber)
        {
            var currentUser = _securityService.GetCurrentUser();

            _runnerService.ScratchRunner(meetingId, eventNumber, runnerNumber, true, currentUser);

            return new JsonResponseBase() { Success = true, Message = "Runner un-scratched" };

        }

        [HttpPost]
        public JsonResponseBase PropId(JObject jsonData)
        {
            dynamic json = jsonData;

            var currentUser = _securityService.GetCurrentUser();

            _runnerService.UpdatePropIds((int)json.meetingId, (int)json.eventNumber, (string)json.data, currentUser);

            return new JsonResponseBase() { Success = true, Message = "Runner propids updated" };

        }

    }
}
