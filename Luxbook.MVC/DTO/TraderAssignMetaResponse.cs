namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Models;
    using System;

    public class MeetingTags
    {
        public int Meeting_Id { get; set; }
        public DateTime Meeting_Date { get; set; }
        public string Country { get; set; }
        public string Type { get; set; }
        public string Region { get; set; }
        public string Venue { get; set; }
        public string Btk_Id { get; set; }
        public int Event_Cnt { get; set; }
        public int Wift_Mtg_Id { get; set; }
        public List<EventTags> Events { get; set; }
    }

    public class EventTags
    {
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Start_Time { get; set; }
        public string Name { get; set; }
        public string Region { get; set; }
    }

    public class TraderTags
    {
        public string Lid { get; set; }
        public string Name { get; set; }
        public int Lvl { get; set; }
        public int Lux { get; set; }
        public int Tab { get; set; }
        public int Sun { get; set; }
    }

    public class TraderAssignMetaResponse : JsonResponseBase
    {
        public List<MeetingTags> Meetings { get; set; }
        public List<TraderTags> Traders { get; set; }
        public List<TraderAssign> Assignments { get; set; }
    }
}