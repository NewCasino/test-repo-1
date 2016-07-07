namespace Luxbook.MVC.Controllers
{
    using System;
    using System.Web.Mvc;
    using AutoMapper;
    using DTO;
    using Infrastructure;
    using ModelBuilders;
    using Models;
    using Services;
    using ViewModels.Rules;

    [RequireAuthentication]

    public partial class RulesController : Controller
    {
        private readonly IRuleService _ruleService;
        private readonly IRulesModelBuilder _rulesModelBuilder;

        public RulesController(IRuleService ruleService, IRulesModelBuilder rulesModelBuilder)
        {
            _ruleService = ruleService;
            _rulesModelBuilder = rulesModelBuilder;

            Mapper.CreateMap<RuleViewModel, Rule>()
                .ForMember(dst => dst.Rule_Id, opt => opt.MapFrom(src => src.RuleId))
                .ForMember(dst => dst.Target_Property, opt => opt.MapFrom(src => src.TargetProperty))
                .ForMember(dst => dst.Target_Value, opt => opt.MapFrom(src => src.TargetValue))
                .ForMember(dst => dst.Property_Name, opt => opt.MapFrom(src => src.PropertyName))
                .ForMember(dst => dst.Date_Created, opt => opt.MapFrom(src => src.DateCreated))
                .ForMember(dst => dst.Comparison_Type, opt => opt.MapFrom(src => Enum.Parse(typeof(Rule.ComparisonType), src.ComparisonType)))
                .ForMember(dst => dst.Type, opt => opt.MapFrom(src => src.Type.ToString()))
                .ForMember(dst => dst.Category, opt => opt.MapFrom(src => src.Category.ToString()))
                .ForMember(dst => dst.Comparison_Operator, opt => opt.MapFrom(src => Enum.Parse(typeof(Rule.ComparisonOperator), src.ComparisonOperator)));
        }

        public virtual ActionResult Manage()
        {
            var rules = _ruleService.GetRules();
            var viewModel = _rulesModelBuilder.CreateManageViewModel(rules);

            return View(viewModel);
        }

        public virtual ActionResult Edit(int ruleId)
        {

            var rule = _ruleService.GetRule(ruleId);

            var viewModel = _rulesModelBuilder.CreateEditViewModel(rule);

            return View(viewModel);
        }

        [HttpPost]
        public virtual JsonResult Edit(RuleViewModel viewModel)
        {
            var response = new JsonResponseBase();
            try
            {
                if (_ruleService.UpdateRule(Mapper.Map<Rule>(viewModel)))
                {
                    response.Success = true;
                    response.Message = "Successfully updated rule";
                }
            }
            catch (Exception ex)
            {
                response.Message = ex.Message;

            }
            return Json(response);

        }

        [HttpPost]
        public virtual JsonResult Add(RuleViewModel viewModel)
        {
            var response = new JsonResponseBase();
            try
            {
                var ruleId = _ruleService.AddRule(Mapper.Map<Rule>(viewModel));
                if (ruleId > 0)
                {
                    response.Success = true;
                    response.Message = string.Format("Successfully added rule {0}", ruleId);
                }
            }
            catch (Exception ex)
            {
                response.Message = ex.Message;

            }
            return Json(response);
        }

        public virtual ActionResult Add()
        {
            var viewModel = _rulesModelBuilder.CreateAddViewModel();

            return View(viewModel);
        }
    }
}