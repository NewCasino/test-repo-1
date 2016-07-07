using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Services
{
    using Repositories;

    public interface IRunnerService
    {
        void UpdateRunnerRoll(int meetingId, int eventNumber, int runnerNumber, string rollType, int roll, string currentUser);

        void UpdateRunnerBoundary(int meetingId, int eventNumber, int runnerNumber, string boundaryType, decimal? boundary, string currentUser);
    }

    public class RunnerService : IRunnerService
    {
        private readonly IRunnerRepository _runnerRepository;
       

        public RunnerService(IRunnerRepository runnerRepository)
        {
            _runnerRepository = runnerRepository;
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

    }
}