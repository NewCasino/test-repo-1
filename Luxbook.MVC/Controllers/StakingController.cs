using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Luxbook.MVC.Models;
using Luxbook.MVC.ViewModels.Staking;

namespace Luxbook.MVC.Controllers
{
    using ModelBuilders;
    using Repositories;

    public partial class StakingController : Controller
    {
        private readonly ISystemRepository _systemRepository;
        private readonly StakingModelBuilder _modelBuilder;

        public StakingController(ISystemRepository systemRepository, StakingModelBuilder modelBuilder)
        {
            _systemRepository = systemRepository;
            _modelBuilder = modelBuilder;
        }

        // GET: Staking
        public virtual ActionResult Index()
        {

            var viewModel = _modelBuilder.CreateStakingIndexViewModel(_systemRepository.GetStakings());

            return View(viewModel);
        }


        [HttpPost]
        public virtual ActionResult Index(StakingIndexViewModel viewModel)
        {
            var stakings = new List<Staking>();

            foreach (var stakingGroup in viewModel.StakingGroups)
            {
                stakings.AddRange(stakingGroup.GreyhoundStakings);
                stakings.AddRange(stakingGroup.HarnessStakings);
                stakings.AddRange(stakingGroup.RacingStakings);
            }

            _systemRepository.UpdateStakings(stakings);

            return RedirectToAction(Actions.Index());
        }
    }
}