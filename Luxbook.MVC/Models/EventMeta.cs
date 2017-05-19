using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class EventMeta
    {
        public int Meeting_Id { get; set; }
        public int Event_No { get; set; }
        public DateTime Start_Time { get; set; }
        public string Type { get; set; }
        public string Country { get; set; }
        public string Venue { get; set; }
        public string Name { get; set; }
        public string Btk_Id { get; set; }
        public string Wift_Unq_Mtg_Id { get; set; }
        public string Fxo_Id { get; set; }
        public string Pa_Mtg_Id { get; set; }
        public string Wift_Unq_Evt_Id { get; set; }
        public string Wift_Src_Id { get; set; }
        public string Wp_EventId { get; set; }
        public string Pa_Evt_Id { get; set; }
        public string Gtx_Id { get; set; }
        public string Bfr_Mkt_Id { get; set; }
        public string Bfr_Mkt_Id_Fp { get; set; }
        public string Book_Spec_Id { get; set; }
        public string Match_Spec_Id { get; set; }
        public int? Ls_Event_Id { get; set; }

        public List<RunnerMeta> Runners { get; set; }

    }
}