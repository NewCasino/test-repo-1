namespace Luxbook.MVC.ViewModels.Rules
{
    using System.Collections.Generic;
    using System.Web.Mvc;

    public class RuleOptionsBase
    {
        public IEnumerable<SelectListItem> ComparisonOperators { get; set; }
        public IEnumerable<SelectListItem> ComparisonTypes { get; set; }
        public IEnumerable<SelectListItem> EventTargetProperties { get; set; }
        public IEnumerable<SelectListItem> RunnerTargetProperties { get; set; }
        public IEnumerable<SelectListItem> RuleCategories { get; set; }
        public IEnumerable<SelectListItem> RuleTypes { get; set; }
    }
}