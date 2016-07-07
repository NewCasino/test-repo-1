namespace Luxbook.MVC.Controllers
{
    using System.Web.Mvc;
    using Infrastructure;
    using ModelBuilders;
    using Services;
    using ViewModels.MaxExposure;

    [RequireAuthentication]
    [RequiredLevel(5)]
    public partial class MaxExposureController : Controller
    {
        private readonly MaxExposureModelBuilder _modelBuilder;
        private readonly IMaxExposureService _maxExposureService;

        public MaxExposureController(MaxExposureModelBuilder modelBuilder, IMaxExposureService maxExposureService)
        {
            _modelBuilder = modelBuilder;
            _maxExposureService = maxExposureService;
        }

        // GET: MaxExposure
        public virtual ActionResult Index()
        {
            var viewModel = _modelBuilder.CreateIndexViewModel(_maxExposureService.GetParameters());
            return View(viewModel);
        }

        [HttpPost]
        public virtual ActionResult Index(MaxExposureIndexViewModel viewModel)
        {
            if (ModelState.IsValid)
            {
                _maxExposureService.UpdateParameters(viewModel);
                viewModel.SuccessMessage = "Values updated successfully";
            }
            else
            {
                viewModel.SuccessMessage = "There was an error updating the values";
            }

            return View(viewModel);
        }
    }
}