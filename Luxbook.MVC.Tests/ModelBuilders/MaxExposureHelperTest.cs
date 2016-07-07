namespace Luxbook.MVC.Tests.ModelBuilders
{
    using System.Collections.Generic;
    using System.Linq;
    using Models;
    using MVC.ModelBuilders;
    using NUnit.Framework;

    [TestFixture]
    internal class MaxExposureHelperTest
    {
        private MaxExposureHelper _helper;
        private List<MaxExposureParameter> _parameters;

        [SetUp]
        public void Setup()
        {
            _helper = new MaxExposureHelper();

            #region test param list

            _parameters = new List<MaxExposureParameter>
            {
                new MaxExposureParameter {Name = "DEF_MAX", Param1 = "G", Param2 = "", Value = 45000.00m},
                new MaxExposureParameter {Name = "DEF_MAX", Param1 = "H", Param2 = "", Value = 30000.00m},
                new MaxExposureParameter {Name = "DEF_MAX", Param1 = "R", Param2 = "", Value = 100000.00m},
                new MaxExposureParameter {Name = "MAX_LIMIT", Param1 = "G", Param2 = "", Value = 150000.00m},
                new MaxExposureParameter {Name = "MAX_LIMIT", Param1 = "H", Param2 = "", Value = 150000.00m},
                new MaxExposureParameter {Name = "MAX_LIMIT", Param1 = "R", Param2 = "", Value = 150000.00m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "1", Param2 = "1", Value = 1.00m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "10", Param2 = "101", Value = 0.25m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "11", Param2 = "1000", Value = 0.20m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "2", Param2 = "3", Value = 0.90m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "3", Param2 = "5", Value = 0.85m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "4", Param2 = "8", Value = 0.75m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "5", Param2 = "11", Value = 0.65m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "6", Param2 = "15", Value = 0.55m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "7", Param2 = "20", Value = 0.45m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "8", Param2 = "35", Value = 0.35m},
                new MaxExposureParameter {Name = "PRICEBAND", Param1 = "9", Param2 = "50", Value = 0.25m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "1", Param2 = "A", Value = 1.00m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "1", Param2 = "B", Value = 0.75m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "1", Param2 = "C", Value = 0.50m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "1", Param2 = "D", Value = 0.25m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "2", Param2 = "A", Value = 0.75m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "2", Param2 = "B", Value = 0.50m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "2", Param2 = "C", Value = 0.25m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "2", Param2 = "D", Value = 0.15m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "3", Param2 = "A", Value = 0.50m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "3", Param2 = "B", Value = 0.25m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "3", Param2 = "C", Value = 0.15m},
                new MaxExposureParameter {Name = "RANKCL", Param1 = "3", Param2 = "D", Value = 0.10m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "G", Param2 = "C", Value = 0.35m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "G", Param2 = "M", Value = 1.00m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "G", Param2 = "P", Value = 0.50m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "H", Param2 = "C", Value = 0.35m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "H", Param2 = "M", Value = 1.00m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "H", Param2 = "P", Value = 0.50m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "R", Param2 = "C", Value = 0.35m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "R", Param2 = "M", Value = 1.00m},
                new MaxExposureParameter {Name = "REGIONTYPE", Param1 = "R", Param2 = "P", Value = 0.75m},
                new MaxExposureParameter {Name = "WGTCL", Param1 = "2", Param2 = "", Value = 0.40m},
                new MaxExposureParameter {Name = "WGTEXP", Param1 = "4", Param2 = "", Value = 0.10m},
                new MaxExposureParameter {Name = "WGTPBAND", Param1 = "3", Param2 = "", Value = 0.20m},
                new MaxExposureParameter {Name = "WGTREG", Param1 = "1", Param2 = "", Value = 0.30m}
            };

            #endregion
        }

        [Test]
        public void GetRankAndConfidenceMean_ShouldReturnCorrectList()
        {
            var results = _helper.GetRankAndConfidenceMean(_parameters);

            Assert.That(results.ConfidenceARank1,Is.EqualTo( 1m));
            Assert.That(results.ConfidenceBRank1,Is.EqualTo( .75m));
            Assert.That(results.ConfidenceCRank1,Is.EqualTo( .5m));
            Assert.That(results.ConfidenceDRank1,Is.EqualTo( .25m));
            Assert.That(results.ConfidenceARank2,Is.EqualTo( .75m));
            Assert.That(results.ConfidenceBRank2,Is.EqualTo( .5m));
            Assert.That(results.ConfidenceCRank2,Is.EqualTo( .25m));
            Assert.That(results.ConfidenceDRank2,Is.EqualTo( .15m));
            Assert.That(results.ConfidenceARank3,Is.EqualTo( .5m));
            Assert.That(results.ConfidenceBRank3,Is.EqualTo( .25m));
            Assert.That(results.ConfidenceCRank3,Is.EqualTo( .15m));
            Assert.That(results.ConfidenceDRank3,Is.EqualTo( .1m));
        }


        [Test]
        public void GetCodeAndRegion_ShouldReturnCorrectList()
        {
            var results = _helper.GetCodeAndRegion(_parameters);

            Assert.That(results.CountryGreyhound.Value,Is.EqualTo(.35m));
            Assert.That(results.MetroGreyhound.Value,Is.EqualTo(1m));
            Assert.That(results.ProvincialGreyhound.Value,Is.EqualTo(.5m));
            Assert.That(results.CountryHarness.Value,Is.EqualTo(.35m));
            Assert.That(results.MetroHarness.Value,Is.EqualTo(1m));
            Assert.That(results.ProvincialHarness.Value,Is.EqualTo(.5m));
            Assert.That(results.CountryThoroughbred.Value,Is.EqualTo(.35m));
            Assert.That(results.MetroThoroughbred.Value,Is.EqualTo(1m));
            Assert.That(results.ProvincialThoroughbred.Value,Is.EqualTo(.75m));
        }

        [Test]
        public void GetPriceBandCoefficients_ShouldReturnCorrectList()
        {
            var results = _helper.GetPriceBandCoefficients(_parameters);


            Assert.That(results.Count, Is.EqualTo(11));
            Assert.That(results.Any(x => x.PriceBand == 1 && x.ActualPrice == 1 && x.Coefficient == 1m));
            Assert.That(results.Any(x => x.PriceBand == 2 && x.ActualPrice == 3 && x.Coefficient == .9m));
            Assert.That(results.Any(x => x.PriceBand == 3 && x.ActualPrice == 5 && x.Coefficient == .85m));
            Assert.That(results.Any(x => x.PriceBand == 4 && x.ActualPrice == 8 && x.Coefficient == .75m));
            Assert.That(results.Any(x => x.PriceBand == 5 && x.ActualPrice == 11 && x.Coefficient == .65m));
            Assert.That(results.Any(x => x.PriceBand == 6 && x.ActualPrice == 15 && x.Coefficient == .55m));
            Assert.That(results.Any(x => x.PriceBand == 7 && x.ActualPrice == 20 && x.Coefficient == .45m));
            Assert.That(results.Any(x => x.PriceBand == 8 && x.ActualPrice == 35 && x.Coefficient == .35m));
            Assert.That(results.Any(x => x.PriceBand == 9 && x.ActualPrice == 50 && x.Coefficient == .25m));
            Assert.That(results.Any(x => x.PriceBand == 10 && x.ActualPrice == 101 && x.Coefficient == .25m));
            Assert.That(results.Any(x => x.PriceBand == 11 && x.ActualPrice == 1000 && x.Coefficient == .2m));
        }

        [Test]
        public void GetWeightedCoefficients_ShouldReturnCorrectList()
        {
            var results = _helper.GetWeightedCoefficients(_parameters);


            Assert.That(results.PriceBand, Is.EqualTo(.2m));
            Assert.That(results.RunnerExpectation, Is.EqualTo(.1m));
            Assert.That(results.Region, Is.EqualTo(.3m));
            Assert.That(results.RankAndConfidence, Is.EqualTo(.4m));
        }

        [Test]
        public void GetMaximumExposure_ShouldReturnCorrectList()
        {
            var results = _helper.GetMaximumExposure(_parameters);

            Assert.That(results.DefaultGreyhound.Value,Is.EqualTo(45000m));
            Assert.That(results.DefaultHarness.Value,Is.EqualTo(30000m));
            Assert.That(results.DefaultThoroughbred.Value,Is.EqualTo(100000m));

            Assert.That(results.MaximumGreyhound.Value,Is.EqualTo(150000m));
            Assert.That(results.MaximumHarness.Value,Is.EqualTo(150000m));
            Assert.That(results.MaximumThoroughbred.Value,Is.EqualTo(150000m));
        }
    }
}