using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class RunnerMeta
    {
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public int Runner_No { get; set; }
        public string Name { get; set; }
        public string Scr { get; set; }
        public string Tab_Prop { get; set; }
    }
}