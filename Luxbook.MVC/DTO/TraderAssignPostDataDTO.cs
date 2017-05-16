using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.DTO
{
    public class TraderAssignPostDataDto
    {
        public string MeetingDate { get; set; }
        public List<DtoSelectedEvent> SelectedEvents { get; set; }
        public List<DtoAssignments> Assignments { get; set; }
    }

    public class DtoSelectedEvent
    {
        public int MeetingId { get; set; }
        public int EventNo { get; set; }
    }

    public class DtoAssignments
    {
        public string AssignedDate { get; set; }
        public DtoAssignedTraders AssignedTraders { get; set; }
    }

    public class DtoAssignedTraders
    {
        public string[] LuxMa { get; set; }
        public string[] LuxTrader { get; set; }
        public string[] TabMa { get; set; }
        public string[] TabTrader { get; set; }
        public string[] SunMa { get; set; }
        public string[] SunTrader { get; set; }
    }
}