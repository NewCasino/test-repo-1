namespace Luxbook.MVC.ModelBuilders
{
    using System.Collections.Generic;
    using System.Linq;
    using Models;
    using ViewModels.Staking;

    public class StakingModelBuilder
    {
        public StakingIndexViewModel CreateStakingIndexViewModel(List<Staking> stakings)
        {
            var viewModel = new StakingIndexViewModel();


            var stakingGroup = CreateGroup(stakings.Where(x => !x.Internationals).ToList());
            stakingGroup.GroupName = "Australian";
            viewModel.StakingGroups.Add(stakingGroup);

             stakingGroup = CreateGroup(stakings.Where(x => x.Internationals).ToList());
            stakingGroup.GroupName = "Internationals";
            viewModel.StakingGroups.Add(stakingGroup);

            return viewModel;
        }

        public StakingIndexViewModel.StakingGroup CreateGroup(List<Staking> stakings)
        {
            var result = new StakingIndexViewModel.StakingGroup();

            result.GreyhoundStakings = stakings.Where(x => x.Race_Type == "G").OrderBy(x=>x.Market).ThenBy(x=> x.Pool_Id).ToList();
            result.HarnessStakings = stakings.Where(x => x.Race_Type == "H").OrderBy(x => x.Market).ThenBy(x => x.Pool_Id).ToList();
            result.RacingStakings = stakings.Where(x => x.Race_Type == "R").OrderBy(x => x.Market).ThenBy(x => x.Pool_Id).ToList();

            return result;
        }

    }
}