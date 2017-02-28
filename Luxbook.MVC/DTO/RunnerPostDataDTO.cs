namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Services;

    public class RunnerPostDataDto
    {
        public int MeetingId;
        public int EventNumber;
        public List<RunnerPropid> Data;
    }
}