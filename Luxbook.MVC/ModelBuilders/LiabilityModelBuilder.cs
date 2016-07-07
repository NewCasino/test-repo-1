using System;
using System.Collections.Generic;
using System.Linq;
using AutoMapper;
using Luxbook.MVC.DTO;
using Luxbook.MVC.Models;

namespace Luxbook.MVC.ModelBuilders
{
    public class LiabilityModelBuilder
    {
        public LiabilityModelBuilder()
        {
            Mapper.CreateMap<RunnerLiability, Liability>();
        }
        public List<Liability> CreateLiabilityDto(List<RunnerLiability> liabilities)
        {
            var liabilityDto = new List<Liability>();

            foreach (var liability in liabilities)
            {
                var dto =
                    liabilityDto.FirstOrDefault(
                        x =>
                            x.Meeting_Id == liability.Meeting_Id && x.Event_No == liability.Event_No &&
                            x.Runner_No == liability.Runner_No);
                if (dto == null)
                {
                    dto = Mapper.Map<Liability>(liability);
                    liabilityDto.Add(dto);
                }

                if (string.Compare(liability.Bet_Type, "WIN", StringComparison.InvariantCultureIgnoreCase) == 0)
                {
                    dto.Win_Liability = liability.Liability;
                }
                else if (string.Compare(liability.Bet_Type, "PLACE", StringComparison.InvariantCultureIgnoreCase) == 0)
                {
                    dto.Place_Liability = liability.Liability;
                }

            }

            return liabilityDto;
        }
    }
}