﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class DroEventMeta
    {
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Start_Time { get; set; }
        public string Type { get; set; }
        public string Country { get; set; }
        public string Venue { get; set; }
        public string Name { get; set; }
        public string Btk_Id { get; set; }
        public string Wfit_Mtg_Id { get; set; }
        public string Fxo_Id { get; set; }
        public string Pa_Mtg_Id { get; set; }
        public string Wift_Evt_Id { get; set; }
        public string Wift_Src_Id { get; set; }
        public string Wp_EventId { get; set; }
        public string Pa_Evt_Id { get; set; }
        public string Gtx_Id { get; set; }
        public string Bfr_Mkt_Id { get; set; }

        public List<DroRunnerMeta> Runners { get; set; }

    }
}