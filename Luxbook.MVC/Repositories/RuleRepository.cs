namespace Luxbook.MVC.Repositories
{
    using System.Collections.Generic;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface IRuleRepository
    {
        List<Rule> GetRules();
        bool UpdateRule(Rule rule);
        int AddRule(Rule rule);
    }

    public class RuleRepository : IRuleRepository
    {
        private readonly IDatabase _database;

        public RuleRepository(IDatabase database)
        {
            _database = database;
        }

        #region Implementation of IRuleRepository

        public List<Rule> GetRules()
        {
            return _database.Query<Rule>("sp_Rules_get").ToList();
        }

        public bool UpdateRule(Rule rule)
        {
            _database.Execute("sp_rules_update", new
            {
                rule.Rule_Id,
                rule.Category,
                rule.Comparison_Operator,
                rule.Comparison_Type,
                rule.Enabled,
                rule.Name,
                rule.Property_Name,
                rule.Target_Property,
                rule.Target_Value,
                rule.Type,
            });
            return true;
        }

        public int AddRule(Rule rule)
        {
            return _database.Query<int>("sp_rules_add", new
            {
                rule.Category,
                rule.Comparison_Operator,
                rule.Comparison_Type,
                rule.Enabled,
                rule.Name,
                rule.Property_Name,
                rule.Target_Property,
                rule.Target_Value,
                rule.Type,
                rule.LID
            }).FirstOrDefault();
        }

        #endregion
    }
}