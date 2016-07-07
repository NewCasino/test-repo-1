using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Luxbook.MVC.Models
{
    public class Property
    {
        public int Property_Id { get; set; }
        public Rule.RuleType RuleType { get; set; }
        public string PropertyName { get; set; }
        public string PropertyCode { get; set; }
    }
}