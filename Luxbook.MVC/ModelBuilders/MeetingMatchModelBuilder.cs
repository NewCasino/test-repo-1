namespace Luxbook.MVC.ModelBuilders
{
    using System.Collections.Generic;
    using AutoMapper;
    using Models;
    using ViewModels.MeetingMatch;

    public class MeetingMatchModelBuilder
    {
        public MeetingMatchModelBuilder()
        {
            Mapper.CreateMap<Bettekk, MeetingMatchIndexViewModel.Venue>();
        }
        public MeetingMatchIndexViewModel CreateMeetingMatchIndexViewModel(List<Bettekk> venues)
        {
            var viewModel = new MeetingMatchIndexViewModel
            {
                RaceTypes = new List<string> { "?", "R", "G", "H" },
                Ranks = new List<int?> { null, 1, 2, 3 },
                Regions = new List<string> { "","M", "P", "C" },
                Venues = Mapper.Map<List<MeetingMatchIndexViewModel.Venue>>(venues)
            };

            return viewModel;
        }
    }
}