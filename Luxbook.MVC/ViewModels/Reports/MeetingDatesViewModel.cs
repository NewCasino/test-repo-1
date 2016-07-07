namespace Luxbook.MVC.ViewModels.Reports
{
    using System;
    using System.Collections.Generic;

    public class MeetingDatesViewModel
    {
        public MeetingDatesViewModel()
        {
            Dates = new List<DateTime>();
        }
        public List<DateTime> Dates { get; set; }

        public string UrlFormat { get; set; }
    }
}