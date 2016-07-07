using System;
using System.Collections.Generic;
using Humanizer;
using Humanizer.Localisation;

namespace Luxbook.MVC.ViewModels.Liability
{
    public class LiabilityIndexViewModel
    {
        public LiabilityIndexViewModel()
        {
            MeetingTypes = new List<string>();
        }

        public List<string> MeetingTypes { get; set; }

        public int? RaceStartTimeFilter { get; set; }
        public int? RaceEndStartTimeFilter { get; set; }


      
    }
}