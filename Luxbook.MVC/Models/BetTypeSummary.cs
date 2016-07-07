namespace Luxbook.MVC.Models
{
    using Common;

    public class BetTypeSummary
    {
        public decimal? Return { get; set; }
        public decimal? BetAmount { get; set; }
        public Enums.BetType BetType { get; set; }
        public int MeetingId { get; set; }
        public int EventNumber { get; set; }

        public decimal? Rebate { get; set; }
    }
}