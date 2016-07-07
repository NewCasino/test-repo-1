using System.Collections.Generic;

namespace Luxbook.MVC.ViewModels.Staking
{
    public class StakingIndexViewModel
    {

        public StakingIndexViewModel()
        {
            StakingGroups = new List<StakingGroup>();
        }

        public List<StakingGroup> StakingGroups { get; set; } 
        public class StakingGroup
        {
            public string GroupName { get; set; }

            public List<Models.Staking> GreyhoundStakings { get; set; } 
            public List<Models.Staking> HarnessStakings { get; set; } 
            public List<Models.Staking> RacingStakings { get; set; } 
        }
    }
}