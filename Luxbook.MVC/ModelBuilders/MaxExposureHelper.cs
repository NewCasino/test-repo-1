namespace Luxbook.MVC.ModelBuilders
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using AutoMapper;
    using Models;
    using ViewModels.MaxExposure;

    public class MaxExposureHelper
    {
        public MaxExposureHelper()
        {
            Mapper.CreateMap<MaxExposureParameter, MaxExposureIndexViewModel.PricebandCoefficient>()
                .ForMember(dst => dst.PriceBand, opt => opt.MapFrom(src => Int32.Parse(src.Param1)))
                .ForMember(dst => dst.ActualPrice, opt => opt.MapFrom(src => Int32.Parse(src.Param2)))
                .ForMember(dst => dst.Coefficient, opt => opt.MapFrom(src => src.Value));
        }

        public MaxExposureIndexViewModel.WeightedCoefficients GetWeightedCoefficients(
            List<MaxExposureParameter> parameters)
        {
            var result = new MaxExposureIndexViewModel.WeightedCoefficients();
            var confidenceLevel = parameters.FirstOrDefault(x => x.Name == "WGTCL");
            if (confidenceLevel != null)
            {
                result.RankAndConfidence = confidenceLevel.Value;
            }
            var expectation = parameters.FirstOrDefault(x => x.Name == "WGTEXP");
            if (expectation != null)
            {
                result.RunnerExpectation = expectation.Value;
            }
            var priceBand = parameters.FirstOrDefault(x => x.Name == "WGTPBAND");
            if (priceBand != null)
            {
                result.PriceBand = priceBand.Value;
            }
            var region = parameters.FirstOrDefault(x => x.Name == "WGTREG");
            if (region != null)
            {
                result.Region = region.Value;
            }

            return result;
        }

        public MaxExposureIndexViewModel.CodeAndRegionCoefficients GetCodeAndRegion(
            List<MaxExposureParameter> parameters)
        {
            var result = new MaxExposureIndexViewModel.CodeAndRegionCoefficients();
            var codeAndRegion = parameters.Where(x => x.Name == "REGIONTYPE").ToList();

            var harness = codeAndRegion.Where(x => x.Param1 == "H").ToList();
            var greys = codeAndRegion.Where(x => x.Param1 == "G").ToList();
            var thoroughbred = codeAndRegion.Where(x => x.Param1 == "R").ToList();

            result.CountryThoroughbred = thoroughbred.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.MetroThoroughbred = thoroughbred.Where(x => x.Param2 == "M").Select(x => x.Value).FirstOrDefault();
            result.ProvincialThoroughbred =
                thoroughbred.Where(x => x.Param2 == "P").Select(x => x.Value).FirstOrDefault();

            result.CountryHarness = harness.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.MetroHarness = harness.Where(x => x.Param2 == "M").Select(x => x.Value).FirstOrDefault();
            result.ProvincialHarness = harness.Where(x => x.Param2 == "P").Select(x => x.Value).FirstOrDefault();

            result.CountryGreyhound = greys.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.MetroGreyhound = greys.Where(x => x.Param2 == "M").Select(x => x.Value).FirstOrDefault();
            result.ProvincialGreyhound = greys.Where(x => x.Param2 == "P").Select(x => x.Value).FirstOrDefault();

            return result;
        }

        public List<MaxExposureIndexViewModel.PricebandCoefficient> GetPriceBandCoefficients(
            List<MaxExposureParameter> parameters)
        {
            return
                Mapper.Map<List<MaxExposureIndexViewModel.PricebandCoefficient>>(
                    parameters.Where(x => x.Name == "PRICEBAND")).OrderBy(x=>x.PriceBand).ToList();
        }

        public MaxExposureIndexViewModel.RankAndConfidenceCoefficients GetRankAndConfidenceMean(
            List<MaxExposureParameter> parameters)
        {
            var result = new MaxExposureIndexViewModel.RankAndConfidenceCoefficients();
            var maxExposureParameters = parameters.Where(x => x.Name == "RANKCL").ToList();

            var rankOne = maxExposureParameters.Where(x => x.Param1 == "1").ToList();
            var rankTwo = maxExposureParameters.Where(x => x.Param1 == "2").ToList();
            var rankThree = maxExposureParameters.Where(x => x.Param1 == "3").ToList();

            result.ConfidenceARank1 = rankOne.Where(x => x.Param2 == "A").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceBRank1 = rankOne.Where(x => x.Param2 == "B").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceCRank1 = rankOne.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceDRank1 = rankOne.Where(x => x.Param2 == "D").Select(x => x.Value).FirstOrDefault();

            result.ConfidenceARank2 = rankTwo.Where(x => x.Param2 == "A").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceBRank2 = rankTwo.Where(x => x.Param2 == "B").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceCRank2 = rankTwo.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceDRank2 = rankTwo.Where(x => x.Param2 == "D").Select(x => x.Value).FirstOrDefault();

            result.ConfidenceARank3 = rankThree.Where(x => x.Param2 == "A").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceBRank3 = rankThree.Where(x => x.Param2 == "B").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceCRank3 = rankThree.Where(x => x.Param2 == "C").Select(x => x.Value).FirstOrDefault();
            result.ConfidenceDRank3 = rankThree.Where(x => x.Param2 == "D").Select(x => x.Value).FirstOrDefault();


            return result;
        }

        public MaxExposureIndexViewModel.MaximumExposure GetMaximumExposure(List<MaxExposureParameter> parameters)
        {
            var result = new MaxExposureIndexViewModel.MaximumExposure();
            var defaultExposures = parameters.Where(x => x.Name == "DEF_MAX").ToList();
            var maximumExposures = parameters.Where(x => x.Name == "MAX_LIMIT").ToList();

            result.DefaultHarness = defaultExposures.Where(x => x.Param1 == "H").Select(x => x.Value).FirstOrDefault();
            result.DefaultGreyhound =
                defaultExposures.Where(x => x.Param1 == "G").Select(x => x.Value).FirstOrDefault();
            result.DefaultThoroughbred =
                defaultExposures.Where(x => x.Param1 == "R").Select(x => x.Value).FirstOrDefault();

            result.MaximumHarness = maximumExposures.Where(x => x.Param1 == "H").Select(x => x.Value).FirstOrDefault();
            result.MaximumGreyhound =
                maximumExposures.Where(x => x.Param1 == "G").Select(x => x.Value).FirstOrDefault();
            result.MaximumThoroughbred =
                maximumExposures.Where(x => x.Param1 == "R").Select(x => x.Value).FirstOrDefault();

            return result;
        }
    }
}