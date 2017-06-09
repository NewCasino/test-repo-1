using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Services
{
    using DTO;
    using Repositories;

    public class RunnerUpdateParameters
    {
        public int MeetingId { get; set; }
        public int EventNumber { get; set; }
        public int RunnerNumber { get; set; }
        public int? PropId { get; set; }
        public int? LsportsEventId { get; set; }
    }

    public interface IRunnerService
    {
        void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser);

        void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType, decimal? boundary, string currentUser);

        void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser);

        void UpdatePropIds(MetadataUpdateDto updateParameters, string currentUser);
    }

    public class RunnerService : IRunnerService
    {
        private readonly IRunnerRepository _runnerRepository;
        private readonly IEventRepository _eventRepository;


        public RunnerService(IRunnerRepository runnerRepository, IEventRepository eventRepository)
        {
            _runnerRepository = runnerRepository;
            _eventRepository = eventRepository;
        }

        public void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser)
        {
            _runnerRepository.UpdateRunnerRoll(meetingId, eventNumber, runnerNumber, rollType, roll, currentUser);
        }


        public void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType,
            decimal? boundary, string currentUser)
        {
            _runnerRepository.UpdateRunnerBoundary(meetingId, eventNumber, runnerNumber, boundaryType, boundary, currentUser);

        }

        public void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser)
        {
            _runnerRepository.UpdateScratchStatus(meetingId, eventNumber, runnerNumber, unscratch, currentUser);
            //TODO is logging required ??
        }

      
        public void UpdatePropIds(MetadataUpdateDto updateParameters, string currentUser)
        {
            foreach (var runner in updateParameters.RunnerData)
            {
                runner.MeetingId = updateParameters.MeetingId;
                runner.EventNumber = updateParameters.EventNumber;
            }

            _runnerRepository.UpdatePropIds(updateParameters.RunnerData, currentUser);
            _eventRepository.UpdateEventMeta(updateParameters.EventData);

        }
    }
}