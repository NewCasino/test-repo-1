namespace Luxbook.MVC.ViewModels.TraderAssignment
{
    using System.Collections.Generic;
    using Reports;

    public class TraderAssignmentIndexViewModel
    {
        public MeetingDatesViewModel MeetingDates { get; set; }

        public List<string> LuxBookies { get; set; }
        public List<string> TabBookies { get; set; }
        public List<string> SunBookies { get; set; }
           
        public class EventAssignment
        {
            public int Meeting_Id { get; set; }
            public string Venue { get; set; }
            public string Type { get; set; }
            public string Country_Code { get; set; }
            public string LuxBookie { get; set; }
            public string SunBookie { get; set; }
            public string TabBookie { get; set; }
        }
    }
}