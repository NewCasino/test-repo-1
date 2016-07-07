namespace Luxbook.MVC.Services
{
    using System.Collections.Generic;
    using System.Linq;
    using Models;
    using Repositories;

    public interface IRuleService
    {
        /// <summary>
        ///     Returns all rules from the repository
        /// </summary>
        /// <returns></returns>
        List<Rule> GetRules();

        /// <summary>
        ///     Returns a single rule. Uncached call currently that grabs all rules from the repo
        ///     We'll cache and use a separate db call later
        /// </summary>
        /// <param name="ruleId"></param>
        /// <returns></returns>
        Rule GetRule(int ruleId);

        bool UpdateRule(Rule rule);
        int AddRule(Rule rule);
    }

    public class RuleService : IRuleService
    {
        private readonly IRuleRepository _repository;
        private readonly ISecurityService _securityService;

        public RuleService(IRuleRepository repository, ISecurityService securityService)
        {
            _repository = repository;
            _securityService = securityService;
        }

        #region Implementation of IRuleService

        /// <summary>
        ///     Returns all rules from the repository
        /// </summary>
        /// <returns></returns>
        public List<Rule> GetRules()
        {
            return _repository.GetRules();
        }


        /// <summary>
        ///     Returns a single rule. Uncached call currently that grabs all rules from the repo
        ///     We'll cache and use a separate db call later
        /// </summary>
        /// <param name="ruleId"></param>
        /// <returns></returns>
        public Rule GetRule(int ruleId)
        {
            return GetRules().FirstOrDefault(x => x.Rule_Id == ruleId);
        }

        public bool UpdateRule(Rule rule)
        {
            NormalizeRule(rule);

            return _repository.UpdateRule(rule);
        }

        private static void NormalizeRule(Rule rule)
        {
            if (rule.Comparison_Type == Rule.ComparisonType.CompareAgainstTargetProperty)
            {
                rule.Target_Value = null;
            }
            else
            {
                rule.Target_Property = null;
            }
        }

        public int AddRule(Rule rule)
        {
            rule.LID = _securityService.GetCurrentUser(); // assign the current user as the creator
            NormalizeRule(rule);
            return _repository.AddRule(rule);
        }

        #endregion
    }
}