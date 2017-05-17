namespace Luxbook.MVC.DTO
{
    using System.Collections.Generic;
    using Models;

    public class DroEventMetaResponse : JsonResponseBase
    {
        public DroEventMeta Event { get; set; }
    }
}