using System.Linq;
using System.Web.Mvc;
using Luxbook.MVC.ModelBuilders;
using Luxbook.MVC.Services;
using Luxbook.MVC.ViewModels.Liability;

namespace Luxbook.MVC.Controllers
{
    public partial class LiabilityController : Controller
    {
        private readonly ICustomAlertsService _customAlertsService;
        private readonly LiabilityModelBuilder _liabilityModelBuilder;

        public LiabilityController(ICustomAlertsService customAlertsService, LiabilityModelBuilder liabilityModelBuilder)
        {
            _customAlertsService = customAlertsService;
            _liabilityModelBuilder = liabilityModelBuilder;
        }

        // GET: Liability
        public virtual ActionResult Index()
        {
            return View(new LiabilityIndexViewModel());
        }

        [HttpGet]
        public virtual JsonResult GetAll()
        {
            // Explicitly allow get as the vulnerability only exists if we send a JSON array. We're sending a JSON object
            // See http://haacked.com/archive/2009/06/25/json-hijacking.aspx/
            var runnerLiabilities = _customAlertsService.GetLiabilities();

            var liabilities = _liabilityModelBuilder.CreateLiabilityDto(runnerLiabilities).OrderBy(x => x.Win_Liability);

            return Json(liabilities, JsonRequestBehavior.AllowGet);
        }
    }
}