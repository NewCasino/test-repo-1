namespace Luxbook.MVC.ModelBuilders
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;
    using AutoMapper;
    using Infrastructure;
    using Models;
    using ViewModels.Rules;

    public interface IRulesModelBuilder
    {
        ManageViewModel CreateManageViewModel(List<Rule> rules);
        EditViewModel CreateEditViewModel(Rule rule);
        AddViewModel CreateAddViewModel();
    }

    public class RulesModelBuilder : IRulesModelBuilder
    {

        private readonly ILanguageManager _languageManager;

        public RulesModelBuilder(ILanguageManager languageManager)
        {
            _languageManager = languageManager;

            Mapper.CreateMap<Rule, RuleViewModel>()
                .ForMember(dst => dst.RuleId, opt => opt.MapFrom(src => src.Rule_Id))
                .ForMember(dst => dst.TargetProperty, opt => opt.MapFrom(src => src.Target_Property))
                .ForMember(dst => dst.TargetValue, opt => opt.MapFrom(src => src.Target_Value))
                .ForMember(dst => dst.PropertyName, opt => opt.MapFrom(src => src.Property_Name))
                .ForMember(dst => dst.DateCreated, opt => opt.MapFrom(src => src.Date_Created))
                .ForMember(dst => dst.ComparisonType, opt => opt.MapFrom(src => src.Comparison_Type.ToString()))
                .ForMember(dst => dst.Type, opt => opt.MapFrom(src => src.Type.ToString()))
                .ForMember(dst => dst.Category, opt => opt.MapFrom(src => src.Category.ToString()))
                .ForMember(dst => dst.ComparisonOperator, opt => opt.MapFrom(src => src.Comparison_Operator.ToString()));

            Mapper.CreateMap<Rule, ManageRuleViewModel>()
                .ForMember(dst => dst.RuleId, opt => opt.MapFrom(src => src.Rule_Id))
                .ForMember(dst => dst.TargetProperty, opt => opt.MapFrom(src => GetPropertyText(src.Target_Property, src)))
                .ForMember(dst => dst.TargetValue, opt => opt.MapFrom(src => src.Target_Value))
                .ForMember(dst => dst.PropertyName, opt => opt.MapFrom(src => GetPropertyText(src.Property_Name, src)))
                .ForMember(dst => dst.DateCreated, opt => opt.MapFrom(src => src.Date_Created))
                .ForMember(dst => dst.ComparisonType, opt => opt.MapFrom(src => _languageManager.GetText(src.Comparison_Type)))
                .ForMember(dst => dst.Type, opt => opt.MapFrom(src => _languageManager.GetText(src.Type)))
                .ForMember(dst => dst.Category, opt => opt.MapFrom(src => src.Category.ToString()))
                .ForMember(dst => dst.ComparisonOperator, opt => opt.MapFrom(src => _languageManager.GetText(src.Comparison_Operator)));
        }

        private string GetPropertyText(string targetProperty, Rule rule)
        {
            if (targetProperty == null)
                return null;

            if (rule.Type == Rule.RuleType.Event)
            {
                var value = Enum.Parse(typeof(Rule.EventTargetProperty), targetProperty);
                return _languageManager.GetText((Rule.EventTargetProperty)value);
            }

            return _languageManager.GetText((Rule.RunnerTargetProperty)Enum.Parse(typeof(Rule.RunnerTargetProperty), targetProperty));

        }

        public ManageViewModel CreateManageViewModel(List<Rule> rules)
        {
            var viewModel = new ManageViewModel
            {
                Rules = Mapper.Map<List<ManageRuleViewModel>>(rules)
            };


            foreach (var rule in viewModel.Rules)
            {

            }


            return viewModel;
        }

        public EditViewModel CreateEditViewModel(Rule rule)
        {
            var viewModel = new EditViewModel();

            viewModel.Rule = Mapper.Map<RuleViewModel>(rule);
            PopulateRuleOptions(viewModel);

            return viewModel;
        }

        public AddViewModel CreateAddViewModel()
        {
            var viewModel = new AddViewModel();
            PopulateRuleOptions(viewModel);

            return viewModel;
        }

        private void PopulateRuleOptions<T>(T viewModel) where T : RuleOptionsBase
        {
            viewModel.ComparisonOperators = GenerateEnumLists<Rule.ComparisonOperator>();
            viewModel.ComparisonTypes = GenerateEnumLists<Rule.ComparisonType>();
            viewModel.EventTargetProperties = GenerateEnumLists<Rule.EventTargetProperty>();
            viewModel.RunnerTargetProperties = GenerateEnumLists<Rule.RunnerTargetProperty>();
            viewModel.RuleCategories = GenerateEnumLists<Rule.RuleCategory>();
            viewModel.RuleTypes = GenerateEnumLists<Rule.RuleType>();
        }

        private IEnumerable<SelectListItem> GenerateEnumLists<T>()
        {
            return Enum.GetValues(typeof(T)).Cast<T>().Select(x => new SelectListItem() { Text = _languageManager.GetText(x), Value = x.ToString() });
        }
    }
}