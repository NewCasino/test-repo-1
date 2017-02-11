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

        void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser);

        void UpdatePropIds(int meetingId, int eventNumber, string data, string currentUser);
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

        public void ScratchRunner(int meetingId, int eventNumber, int runnerNumber, bool unscratch, string currentUser)
        {
            _runnerRepository.ScratchRunner(meetingId, eventNumber, runnerNumber, unscratch, currentUser);
            //TODO is logging required ??
        }

        // update runners propids
        public void UpdatePropIds(int meetingId, int eventNumber, string data, string currentUser)
        {
            char[] delim1 = {','};
            char[] delim2 = {':'};
            string[] runners = data.Split(delim1);
            foreach (string runner in runners)
            {
                string[] item = runner.Split(delim2);
                _runnerRepository.UpdatePropId(meetingId, eventNumber, Int32.Parse(item[0]), Int32.Parse(item[1]), currentUser);
            }
            //TODO is logging required ??
        }


    }
}