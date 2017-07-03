namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Models;
    using System;
    using System.Linq;
    using System.Security.Cryptography;
    using System.Text;

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

    public class EventAssignMetaResponse : JsonResponseBase
    {

        public List<EventMeta> Events { get; set; } = new List<EventMeta>();

        public class EventMeta
        {
            public int MeetingId { get; set; }

            public int Event_No { get; set; }
            // venue name
            public string Venue { get; set; }

            public int EventsInMeeting { get; set; }
            public string Type { get; set; }

            public DateTime StartTime { get; set; }
            public DateTime MeetingDate { get; set; }

            public List<TraderAssign> Traders { get; set; }
            public string Country { get; set; }

            /// <summary>
            /// Returns the SHA1 hash of all ordered trader assignments
            /// This can be used to compare against other events and see if they have the same assignments
            /// </summary>
            public string TraderAssignmentHash
            {
                get
                {
                    var orderedTraders = Traders.OrderBy(x => x.LID).ThenBy(x => x.Assignment_Date);

                    using (var sha1 = new SHA1Managed())
                    {
                        var joinedHashes = string.Join("-", orderedTraders.Select(x => x.GetAssignmentString()));
                        var hashed = sha1.ComputeHash(Encoding.ASCII.GetBytes(joinedHashes));

                        return string.Join("",hashed.Select(x=> x.ToString("x2")));
                    }
                }
            }
        }



    }

}