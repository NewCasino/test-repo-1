namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Models;

    public class EventMetaResponse : JsonResponseBase
    {
        public EventMeta Event { get; set; }
        public List<RunnerMeta> Runners { get; set; }
    }
}