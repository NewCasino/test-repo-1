namespace Luxbook.MVC.ViewModels.Alerts
{
    using System;
    using System.Collections.Generic;
    using Humanizer;
    using Humanizer.Localisation;

    public class IndexViewModel
    {
        public IndexViewModel()
        {
            MeetingTypes = new List<string>();
        }

        public Dictionary<string, List<Alert>> AlertGroups { get; set; }

        public List<string> MeetingTypes { get; set; }

        public decimal PercentageFilter { get; set; }

        public int? RaceStartTimeFilter { get; set; }
        public int? RaceEndStartTimeFilter { get; set; }
        

        public class Alert : Models.Alert
        {
            public string Last_Triggered_Humanized
            {
                get {  return (DateTime.Now - Last_Triggered).Humanize(3, minUnit: TimeUnit.Second); }
            }

            public string Start_Time_Humanized
            {
                get
                {
                    var startedTime = (Start_Time - DateTime.Now);
                    var startTimeHumanized = startedTime.Humanize(3, minUnit: TimeUnit.Second);
                    // if started we need to add a postfix
                    if (startedTime.TotalSeconds < 0)
                    {
                        startTimeHumanized += " ago";
                    }
                    return startTimeHumanized;
                }
            } 
        }
    }
}