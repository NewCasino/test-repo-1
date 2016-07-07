using System;
using Humanizer;
using Humanizer.Localisation;
using Luxbook.MVC.Models;

namespace Luxbook.MVC.DTO
{
    public class Liability : RunnerLiability
    {
        public decimal Win_Liability { get; set; }
        public decimal Place_Liability { get; set; }

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