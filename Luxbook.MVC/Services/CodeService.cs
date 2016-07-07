namespace Luxbook.MVC.Services
{
    using System;
    using Common;

    public interface ICodeService
    {
        Enums.RaceType GetRaceTypeFromCode(string code);
        string GetCodeFromRaceType(Enums.RaceType raceType);
    }

    public class CodeService : ICodeService
    {
        public Enums.RaceType GetRaceTypeFromCode(string code)
        {
            switch (code)
            {
                case "G":
                    return Enums.RaceType.Greyhounds;
                case "H":
                    return Enums.RaceType.Harness;
                case "R":
                    return Enums.RaceType.Races;
            }

            throw new ArgumentException("Unknown code " + code);
        }

        public string GetCodeFromRaceType(Enums.RaceType raceType)
        {
            switch (raceType)
            {
                case Enums.RaceType.Greyhounds:
                    return "G";
                case Enums.RaceType.Harness:
                    return "H";
                case Enums.RaceType.Races:
                    return "R";
            }

            throw new ArgumentException("Unknown race type " + raceType);
        }
    }
}