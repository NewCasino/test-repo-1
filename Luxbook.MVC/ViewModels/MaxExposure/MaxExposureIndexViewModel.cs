namespace Luxbook.MVC.ViewModels.MaxExposure
{
    using System.Collections.Generic;

    public class MaxExposureIndexViewModel
    {
        public WeightedCoefficients WeightedCoefficientsList { get; set; }

        public CodeAndRegionCoefficients CodeAndRegionMean { get; set; }
        public RankAndConfidenceCoefficients RankAndConfidenceMean { get; set; }
        public List<PricebandCoefficient> PriceBandCoefficients { get; set; }

        public MaximumExposure MaximumExposures { get; set; }

        public string ErrorMessage { get; set; }
        public string SuccessMessage { get; set; }

        public class MaximumExposure
        {
            public decimal? DefaultThoroughbred { get; set; }
            public decimal? DefaultGreyhound { get; set; }
            public decimal? DefaultHarness { get; set; }
            public decimal? MaximumThoroughbred { get; set; }
            public decimal? MaximumGreyhound { get; set; }
            public decimal? MaximumHarness { get; set; }
        }
        public class RankAndConfidenceCoefficients
        {
            public decimal?  ConfidenceARank1 { get; set; }
            public decimal?  ConfidenceARank2 { get; set; }
            public decimal?  ConfidenceARank3 { get; set; }
            public decimal?  ConfidenceBRank1 { get; set; }
            public decimal?  ConfidenceBRank2 { get; set; }
            public decimal?  ConfidenceBRank3 { get; set; }
            public decimal?  ConfidenceCRank1 { get; set; }
            public decimal?  ConfidenceCRank2 { get; set; }
            public decimal?  ConfidenceCRank3 { get; set; }
            public decimal?  ConfidenceDRank1 { get; set; }
            public decimal?  ConfidenceDRank2 { get; set; }
            public decimal?  ConfidenceDRank3 { get; set; }
        }
        public class CodeAndRegionCoefficients
        {
            public decimal? MetroThoroughbred { get; set; }
            public decimal? ProvincialThoroughbred { get; set; }
            public decimal? CountryThoroughbred { get; set; }
            public decimal? MetroHarness { get; set; }
            public decimal? ProvincialHarness { get; set; }
            public decimal? CountryHarness { get; set; }
            public decimal? MetroGreyhound { get; set; }
            public decimal? ProvincialGreyhound { get; set; }
            public decimal? CountryGreyhound { get; set; }

        }
        public class WeightedCoefficients
        {
            public decimal? Region { get; set; }
            public decimal? RankAndConfidence { get; set; }
            public decimal? PriceBand { get; set; }
            public decimal? RunnerExpectation { get; set; }
        }
        public class PricebandCoefficient
        {
            public int PriceBand { get; set; }
            public decimal ActualPrice { get; set; }
            public decimal? Coefficient { get; set; }
        }
    }
}