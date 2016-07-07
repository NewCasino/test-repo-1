namespace Luxbook.MVC.Models
{
    using System;

    public class Alert
    {
        /// <summary>
        ///     The actual instance of this alert. A rule can have many alerts
        /// </summary>
        public int Alert_Id { get; set; }

        /// <summary>
        ///     References the rule being violated
        /// </summary>
        public int Rule_Id { get; set; }

        /// <summary>
        ///     Common name for the rule
        /// </summary>
        public string Rule_Name { get; set; }

        public Rule.RuleCategory Rule_Category { get; set; }

        /// <summary>
        ///     Actual meeting (i.e. instance of a rule at a venue)
        /// </summary>
        public int Meeting_Id { get; set; }

        public string Meeting_Type { get; set; }

        public int Event_No { get; set; }

        public string Venue { get; set; }

        public string Property_Name { get; set; }
        public string Target_Property { get; set; }
        /// <summary>
        ///     Number of the runner/racer for a particular meeting
        /// </summary>
        public int Runner_No { get; set; }

        /// <summary>
        ///     Common name for the runner/racer
        /// </summary>
        public string Runner_Name { get; set; }

        /// <summary>
        ///     Current computed value for the field that violated the rule
        /// </summary>
        public decimal Current_Value { get; set; }

        /// <summary>
        ///     Value we compared against
        /// </summary>
        public decimal Target_Value { get; set; }

        public DateTime? Date_Acknowledged { get; set; }
        public string Acknowledged_By { get; set; }

        public DateTime Last_Triggered { get; set; }

        public DateTime Date_Created { get; set; }

        public DateTime Start_Time { get; set; }

        public decimal? Betfair_Total_Match { get; set; }
    }
}