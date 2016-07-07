namespace Luxbook.MVC.ModelBuilders
{
    using System.Collections.Generic;
    using Models;
    using ViewModels.MaxExposure;

    public class MaxExposureModelBuilder
    {
        private readonly MaxExposureHelper _helper;

        public MaxExposureModelBuilder(MaxExposureHelper helper)
        {
            _helper = helper;
        }

        public MaxExposureIndexViewModel CreateIndexViewModel(List<MaxExposureParameter> parameters)
        {
            var viewModel = new MaxExposureIndexViewModel();

            viewModel.WeightedCoefficientsList = _helper.GetWeightedCoefficients(parameters);
            viewModel.CodeAndRegionMean = _helper.GetCodeAndRegion(parameters);
            viewModel.PriceBandCoefficients = _helper.GetPriceBandCoefficients(parameters);
            viewModel.RankAndConfidenceMean = _helper.GetRankAndConfidenceMean(parameters);
            viewModel.MaximumExposures = _helper.GetMaximumExposure(parameters);
            return viewModel;
        }
    }
}