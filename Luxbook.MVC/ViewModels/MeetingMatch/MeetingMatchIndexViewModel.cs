namespace Luxbook.MVC.ViewModels.MeetingMatch
{
    using System.Collections.Generic;
    using Models;

    public class MeetingMatchIndexViewModel
    {
        public List<Venue> Venues { get; set; }

        public List<string> RaceTypes { get; set; }

        public List<int?> Ranks { get; set; }

        public List<string> Regions { get; set; }


        public class Venue : Bettekk
        {
            public string ServerType
            {
                get
                {
                    return Type;
                }
            }
        } 
    }
}