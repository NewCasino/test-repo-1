namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Models;
    using Repositories;
    using DTO;

    public interface ITraderAssignService
    {
        TraderAssignMetaResponse GetAssignments(string meetingDate);
        List<EventAssignMetaResponse> GetAssignmentsByDate(string Mode, string Date);
        TraderAssignMetaResponse SaveAssignments(TraderAssignPostDataDto postData);
    }

    public class TraderAssignService : ITraderAssignService
    {
        private readonly ITraderAssignRepository _traderAssignRepository;

        public TraderAssignService(ITraderAssignRepository traderAssignRepository)
        {
            _traderAssignRepository = traderAssignRepository;
        }

        public TraderAssignMetaResponse GetAssignments(string meetingDate)
        {
            return _traderAssignRepository.GetAssignments(meetingDate);
        }

        public List<EventAssignMetaResponse> GetAssignmentsByDate(string Mode, string Date)
        {
            return _traderAssignRepository.GetAssignmentsByDate(Mode, Date);
        }

        public TraderAssignMetaResponse SaveAssignments(TraderAssignPostDataDto postData)
        {
            var assignments = new List<TraderAssign>();

            foreach (var dtoEvent in postData.SelectedEvents)
            {
                // events can be assigned to multiple traders
                foreach (var assignment in postData.Assignments)
                {
                    // traders can be assigned on multiple days
                    foreach (var date in assignment.AssignedDates)
                    {
                        var traderAssign = new TraderAssign()
                        {
                            LID = assignment.Lid,
                            Assignment_Date = date,
                            Event_No = dtoEvent.EventNo,
                            Meeting_Id = dtoEvent.MeetingId,
                            Lux_Ma = assignment.LuxMa,
                            Lux_Trader = assignment.LuxTrader,
                            Sun_Ma = assignment.SunMa,
                            Sun_Trader = assignment.SunTrader,
                            Tab_Ma = assignment.TabMa,
                            Tab_Trader = assignment.TabTrader,
                        };
                        assignments.Add(traderAssign);
                    }

                }
                _traderAssignRepository.SaveAssignments(assignments);
            }

            return _traderAssignRepository.GetAssignments(postData.MeetingDate);

            //TODO is logging required ??
        }
    }
}