namespace Luxbook.MVC.Models
{
    using Trading.Common;

    public class EventTradingSummary
    {
        public decimal? Return { get; set; }
        public decimal? BetAmount { get; set; }
        public Enums.Jurisdiction Jurisdiction { get; set; }
        public int MeetingId { get; set; }
        public int EventNumber { get; set; }

        public decimal? Rebate { get; set; }
    }
}