namespace Luxbook.MVC.DTO
{
    using System;
    using System.Collections.Generic;

    public class TraderAssignPostDataDto
    {
        public string MeetingDate { get; set; }
        public List<SelectedEventDto> SelectedEvents { get; set; }
        public List<AssignedTraderDto> Assignments { get; set; }

        public class SelectedEventDto
        {
            public int MeetingId { get; set; }
            public int EventNo { get; set; }
        }

        public class AssignedTraderDto
        {
            /// <summary>
            ///     Trader username
            /// </summary>
            public string Lid { get; set; }

            public List<DateTime> AssignedDates { get; set; }
            public bool LuxMa { get; set; }
            public bool LuxTrader { get; set; }
            public bool TabMa { get; set; }
            public bool TabTrader { get; set; }
            public bool SunMa { get; set; }
            public bool SunTrader { get; set; }
        }
    }
}