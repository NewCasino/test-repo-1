namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using AutoMapper;
    using Models;
    using Repositories;
    using DTO;

    public interface ITraderAssignService
    {
        TraderAssignMetaResponse GetAssignments(string meetingDate);
        EventAssignMetaResponse GetAssignmentsByDate(string mode, string date);
        TraderAssignMetaResponse SaveAssignments(TraderAssignPostDataDto postData);
    }

    public class TraderAssignService : ITraderAssignService
    {
        private readonly ITraderAssignRepository _traderAssignRepository;

        public TraderAssignService(ITraderAssignRepository traderAssignRepository)
        {
            _traderAssignRepository = traderAssignRepository;
            Mapper.Initialize(cfg => cfg.CreateMap<TraderAssignWithMeta, TraderAssign>());
        }

        public TraderAssignMetaResponse GetAssignments(string meetingDate)
        {
            return _traderAssignRepository.GetAssignments(meetingDate);
        }

        public EventAssignMetaResponse GetAssignmentsByDate(string mode, string date)
        {
            List<TraderAssignWithMeta> assignments = _traderAssignRepository.GetAssignmentsByDate(mode, date);


            var assignmentsByEvent = assignments.GroupBy(x => new { x.Meeting_Id, x.Event_No, x.Start_Time, x.Meeting_Date, x.Venue, x.EventsInMeeting, x.Country });
            var result = new EventAssignMetaResponse() { Success = true };

            foreach (var eventAssignments in assignmentsByEvent)
            {
                var @event = new EventAssignMetaResponse.EventMeta();
                @event.MeetingId = eventAssignments.Key.Meeting_Id;
                @event.Event_No = eventAssignments.Key.Event_No;
                @event.StartTime = eventAssignments.Key.Start_Time;
                @event.MeetingDate = eventAssignments.Key.Meeting_Date;
                @event.Name = eventAssignments.Key.Venue;
                @event.EventsInMeeting = eventAssignments.Key.EventsInMeeting;
                @event.Traders = Mapper.Map<List<TraderAssign>>(eventAssignments);
                @event.Country = eventAssignments.Key.Country;
                result.Events.Add(@event);
            }

            return result;
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
            }

            _traderAssignRepository.SaveAssignments(assignments);


            return _traderAssignRepository.GetAssignments(postData.MeetingDate);

            //TODO is logging required ??
        }
    }
}