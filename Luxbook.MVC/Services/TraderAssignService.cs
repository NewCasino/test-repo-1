﻿namespace Luxbook.MVC.Services
{
    using System;
    using System.Collections.Generic;
    using Models;
    using Repositories;
    using DTO;

    public interface ITraderAssignService
    {
        TraderAssignMetaResponse GetAssignments(string meetingDate);
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

        public TraderAssignMetaResponse SaveAssignments(TraderAssignPostDataDto postData)
        {
            foreach (string meetingId in postData.meetings)
            {
                _traderAssignRepository.SaveAssignment(postData.meetingDate, Int32.Parse(meetingId), postData.env.ToUpper(), postData.traders, postData.analysts);
            }

            return _traderAssignRepository.GetAssignments(postData.meetingDate);

            //TODO is logging required ??
        }

    }
}