namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Models;
    using Services;

    public class MetadataUpdateDto
    {
        public int MeetingId { get; set; }
        public int EventNumber { get; set; }
        public List<RunnerUpdateParameters> RunnerData { get; set; }
        public EventMeta EventData { get; set; }
    }
}