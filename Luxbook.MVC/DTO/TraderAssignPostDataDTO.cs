using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.DTO
{
    public class TraderAssignPostDataDto
    {
        public string meetingDate;
        public string env;
        public List<string> meetings;
        public string traders;
        public string analysts;
    }
}