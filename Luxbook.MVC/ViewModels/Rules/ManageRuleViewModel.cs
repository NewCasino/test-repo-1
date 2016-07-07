namespace Luxbook.MVC.ViewModels.Rules
{
    using System;

    public class ManageRuleViewModel 
    {
        public int RuleId { get; set; }
        public string Name { get; set; }
        public string PropertyName { get; set; }
        public string ComparisonOperator { get; set; }

        /// <summary>
        ///     This is used if ComparisonType is FixedValue
        /// </summary>
        public decimal? TargetValue { get; set; }

        public string ComparisonType { get; set; }

        /// <summary>
        ///     This is used if the ComparisonType is CompareAgainstTargetProperty
        /// </summary>
        public string TargetProperty { get; set; }

        public string Type { get; set; }
        public string Category { get; set; }
        public bool Enabled { get; set; }
        public DateTime DateCreated { get; set; }
    }
}