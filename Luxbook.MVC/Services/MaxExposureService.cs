namespace Luxbook.MVC.Services
{
    using System.Collections.Generic;
    using System.Linq;
    using Models;
    using Repositories;
    using ViewModels.MaxExposure;

    public interface IMaxExposureService
    {
        List<MaxExposureParameter> GetParameters();
        void UpdateParameters(MaxExposureIndexViewModel viewModel);
    }

    public class MaxExposureService : IMaxExposureService
    {
        private readonly IMaxExposureRepository _repository;

        public MaxExposureService(IMaxExposureRepository repository)
        {
            _repository = repository;
        }

        public List<MaxExposureParameter> GetParameters()
        {
            return _repository.GetParameters();
        }


        public void UpdateParameters(MaxExposureIndexViewModel viewModel)
        {
            var parameters = new List<MaxExposureParameter>();

            // price band params
            parameters.AddRange(
                viewModel.PriceBandCoefficients.Select(
                    c =>
                        new MaxExposureParameter("PRICEBAND", c.PriceBand.ToString(), c.ActualPrice.ToString(),
                            c.Coefficient)));

            // code and region params
            AddParameter(parameters, "REGIONTYPE", "R", "P", viewModel.CodeAndRegionMean.ProvincialThoroughbred);
            AddParameter(parameters, "REGIONTYPE", "R", "C", viewModel.CodeAndRegionMean.CountryThoroughbred);
            AddParameter(parameters, "REGIONTYPE", "R", "M", viewModel.CodeAndRegionMean.MetroThoroughbred);
            AddParameter(parameters, "REGIONTYPE", "H", "P", viewModel.CodeAndRegionMean.ProvincialHarness);
            AddParameter(parameters, "REGIONTYPE", "H", "C", viewModel.CodeAndRegionMean.CountryHarness);
            AddParameter(parameters, "REGIONTYPE", "H", "M", viewModel.CodeAndRegionMean.MetroHarness);
            AddParameter(parameters, "REGIONTYPE", "G", "P", viewModel.CodeAndRegionMean.ProvincialGreyhound);
            AddParameter(parameters, "REGIONTYPE", "G", "C", viewModel.CodeAndRegionMean.CountryGreyhound);
            AddParameter(parameters, "REGIONTYPE", "G", "M", viewModel.CodeAndRegionMean.MetroGreyhound);

            // confidence params
            AddParameter(parameters, "RANKCL", "1", "A", viewModel.RankAndConfidenceMean.ConfidenceARank1);
            AddParameter(parameters, "RANKCL", "1", "B", viewModel.RankAndConfidenceMean.ConfidenceBRank1);
            AddParameter(parameters, "RANKCL", "1", "C", viewModel.RankAndConfidenceMean.ConfidenceCRank1);
            AddParameter(parameters, "RANKCL", "1", "D", viewModel.RankAndConfidenceMean.ConfidenceDRank1);
            AddParameter(parameters, "RANKCL", "2", "A", viewModel.RankAndConfidenceMean.ConfidenceARank2);
            AddParameter(parameters, "RANKCL", "2", "B", viewModel.RankAndConfidenceMean.ConfidenceBRank2);
            AddParameter(parameters, "RANKCL", "2", "C", viewModel.RankAndConfidenceMean.ConfidenceCRank2);
            AddParameter(parameters, "RANKCL", "2", "D", viewModel.RankAndConfidenceMean.ConfidenceDRank2);
            AddParameter(parameters, "RANKCL", "3", "A", viewModel.RankAndConfidenceMean.ConfidenceARank3);
            AddParameter(parameters, "RANKCL", "3", "B", viewModel.RankAndConfidenceMean.ConfidenceBRank3);
            AddParameter(parameters, "RANKCL", "3", "C", viewModel.RankAndConfidenceMean.ConfidenceCRank3);
            AddParameter(parameters, "RANKCL", "3", "D", viewModel.RankAndConfidenceMean.ConfidenceDRank3);

            // max exposures
            AddParameter(parameters, "DEF_MAX", "G", null, viewModel.MaximumExposures.DefaultGreyhound);
            AddParameter(parameters, "DEF_MAX", "H", null, viewModel.MaximumExposures.DefaultHarness);
            AddParameter(parameters, "DEF_MAX", "R", null, viewModel.MaximumExposures.DefaultThoroughbred);
            AddParameter(parameters, "MAX_LIMIT", "G", null, viewModel.MaximumExposures.MaximumGreyhound);
            AddParameter(parameters, "MAX_LIMIT", "H", null, viewModel.MaximumExposures.MaximumHarness);
            AddParameter(parameters, "MAX_LIMIT", "R", null, viewModel.MaximumExposures.MaximumThoroughbred);

            // weighted coefficients
            AddParameter(parameters, "WGTCL", "2", null, viewModel.WeightedCoefficientsList.RankAndConfidence);
            AddParameter(parameters, "WGTEXP", "4", null, viewModel.WeightedCoefficientsList.RunnerExpectation);
            AddParameter(parameters, "WGTPBAND", "3", null, viewModel.WeightedCoefficientsList.PriceBand);
            AddParameter(parameters, "WGTREG", "1", null, viewModel.WeightedCoefficientsList.Region);


            _repository.UpdateParameters(parameters);
        }

        private void AddParameter(List<MaxExposureParameter> parameters, string name, string param1, string param2,
            decimal? value)
        {
            parameters.Add(new MaxExposureParameter(name, param1, param2, value));
        }
    }
}