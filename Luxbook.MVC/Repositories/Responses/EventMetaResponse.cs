using Luxbook.MVC.DTO;
using Luxbook.MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Repositories.Responses
{
    public class EventMetaResponse : JsonResponseBase
    {
        public EventMeta Event { get; set; }
        public RunnerMeta[] Runners { get; set; }
    }
}