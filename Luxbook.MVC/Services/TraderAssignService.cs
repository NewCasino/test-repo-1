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
            foreach (DtoSelectedEvent dtoEvent in postData.SelectedEvents)
            {
                _traderAssignRepository.SaveAssignments(postData.MeetingDate, dtoEvent, postData.Assignments);
            }

            return _traderAssignRepository.GetAssignments(postData.MeetingDate);

            //TODO is logging required ??
        }
    }
}