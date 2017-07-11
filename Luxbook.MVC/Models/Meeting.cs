namespace Luxbook.MVC.Models
{
    using System;

    public class Meeting
    {
        public DateTime? MeetingDate { get; set; }
        public int Meeting_Id { get; set; }
        public string Country { get; set; }
        public string Type { get; set; }
        public string Region { get; set; }
        public string Venue { get; set; }
        public string BtkId { get; set; }
        public int Events { get; set; }
        public int WiftUnqMtgId { get; set; }
    }
}