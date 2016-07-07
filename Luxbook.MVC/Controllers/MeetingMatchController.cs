using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Luxbook.MVC.Controllers
{
    using DTO;
    using ModelBuilders;
    using Models;
    using Repositories;
    using ViewModels.MeetingMatch;

    public partial class MeetingMatchController : Controller
    {
        private readonly MeetingMatchModelBuilder _modelBuilder;
        private readonly ISystemRepository _systemRepository;

        public MeetingMatchController(MeetingMatchModelBuilder modelBuilder, ISystemRepository systemRepository)
        {
            _modelBuilder = modelBuilder;
            _systemRepository = systemRepository;
        }

        // GET: MeetingMatch
        public virtual ActionResult Index()
        {
            var venueCodes = _systemRepository.GetVenueCodes();

            var viewModel = _modelBuilder.CreateMeetingMatchIndexViewModel(venueCodes);
            return View(viewModel);
        }

        [HttpPost]
        public virtual JsonResult Index(List<Bettekk> venues)
        {
            if (ModelState.IsValid)
            {
                _systemRepository.UpdateVenues(venues);
            }

            return Json(new JsonResponseBase() { Success = true, Message = "Venues updated" });
        }
    }
}